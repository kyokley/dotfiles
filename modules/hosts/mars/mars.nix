{inputs, ...}: let
  home_modules = with inputs.self.modules.homeManager; [
    dev
    opencode
    distributedBuilds
    systemd-services
    syncthing
  ];

  nixos_modules = with inputs.self.modules.nixos; [
    laptop
    distributedBuilds
    tailscale
  ];
in {
  flake.modules = {
    homeManager."yokley@mars" = {
      pkgs,
      lib,
      username,
      config,
      ...
    }: let
      cd_paths = [
        "/home/${username}/workspace"
      ];
      n64 = pkgs.writeShellApplication {
        name = "n64";
        text = ''
          exec ${pkgs.mupen64plus}/bin/mupen64plus --datadir "${config.home.homeDirectory}/.local/share/mupen64plus/data" "$@"
        '';
      };
    in {
      imports = home_modules;
      programs.git.settings.user.email = "kyokley@mars";

      home = {
        sessionVariables = {
          QTILE_NET_INTERFACE = "wlp1s0";
          CDPATH = lib.concatStringsSep ":" cd_paths;
        };

        packages = [
          pkgs.brightnessctl
          pkgs.mattermost-desktop
          pkgs.lutris
          pkgs.steam
          pkgs.mupen64plus
          n64
        ];

        stateVersion = "24.05"; # Don't touch me!
      };
    };

    nixos.mars = {
      pkgs,
      lib,
      config,
      modulesPath,
      ...
    }: {
      imports =
        nixos_modules
        ++ [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

      # Bootloader.
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        supportedFilesystems = ["bcachefs"];
        kernelPackages = pkgs.linuxPackages_latest;
        initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "uas" "sd_mod"];
        initrd.kernelModules = ["amdgpu"];
        kernelModules = ["kvm-amd" "amdgpu"];
        # pcie_aspm=off prevents PCIe link state changes on suspend that
        # cause the MT7921E to become unresponsive. Costs a small amount
        # of battery — remove if you need the power savings.
        kernelParams = ["pcie_aspm=off"];
        extraModulePackages = [];
        extraModprobeConfig = ''
          # Mediatek MT7921E can be unstable around suspend/resume with ASPM/CLC.
          options mt7921e disable_aspm=Y
          options mt7921e disable_clc=Y
        '';
      };

      powerManagement.enable = true;

      system.stateVersion = "24.05"; # Don't touch me!

      virtualisation.docker.daemon.settings = {
        "group" = "docker";
        "hosts" = [
          "fd://"
        ];
        "live-restore" = true;
        "log-driver" = "journald";
        "dns" = [
          "8.8.8.8"
        ];
      };

      networking.networkmanager = {
        wifi.powersave = false;
        settings = {
          device = {
            "wifi.scan-rand-mac-address" = "no";
          };
          connection = {
            "wifi.cloned-mac-address" = "preserve";
            "ethernet.cloned-mac-address" = "preserve";
          };
        };
      };

      services = {
        xserver = {
          videoDrivers = ["amdgpu"];
        };

        udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
        '';
      };

      environment = {
        systemPackages = with pkgs; [
          proton-vpn
          spotify
          steam-devices-udev-rules
        ];

        # MT7921E often fails to reinitialize after resume — reload the module
        # to force a clean hardware reset, then let NM reconnect automatically.
        etc."systemd/system-sleep/99-mt7921e-reload" = {
          mode = "0755";
          text = ''
            #!${pkgs.runtimeShell}
            case "$1" in
              pre)
                # Tear down before suspend so NM doesn't hold the device
                ${pkgs.networkmanager}/bin/nmcli device disconnect wlp1s0 >/dev/null 2>&1 || true
                ;;
              post)
                # Give PCIe subsystem time to settle
                ${pkgs.coreutils}/bin/sleep 3

                # If the device isn't responding, reload the kernel module
                if ! ${pkgs.networkmanager}/bin/nmcli -t -f GENERAL.STATE device show wlp1s0 >/dev/null 2>&1; then
                  ${pkgs.kmod}/bin/modprobe -r mt7921e
                  ${pkgs.coreutils}/bin/sleep 1
                  ${pkgs.kmod}/bin/modprobe mt7921e
                  ${pkgs.coreutils}/bin/sleep 2
                fi

                # Let NM reconnect automatically (it will, but ensure device is available)
                ${pkgs.networkmanager}/bin/nmcli device connect wlp1s0 >/dev/null 2>&1 || true
                ;;
            esac
          '';
        };
      };

      fileSystems = {
        "/" = {
          device = "UUID=12b2a9cf-4d19-43d9-a9db-0942d019fa4f";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/B1C7-96E8";
          fsType = "vfat";
          options = ["fmask=0022" "dmask=0022"];
        };
      };

      swapDevices = [
        {device = "/dev/disk/by-uuid/beaf0a2b-05bb-4517-8ead-65a47660b6f6";}
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.graphics.enable32Bit = true;

      virtualisation = {
        vmVariant = {
          # Hyprland crashes on NixOS if /usr/share/icons doesn't exist.
          # In a VM, this path may not be present by default.
          systemd.tmpfiles.rules = [
            "d /usr/share/icons 0755 root root -"
          ];

          # Set env vars that Hyprland/aquamarine need
          # to function with virtio GPUs.
          environment.sessionVariables = {
            WLR_NO_HARDWARE_CURSORS = "1";
            WLR_RENDERER_ALLOW_SOFTWARE = "1";
            AQ_NO_KMS_REQUIREMENT = "1";
          };

          # Forward host:2222 → guest:22 for SSH debugging
          virtualisation.forwardPorts = [
            {
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }
          ];

          # Enable SSH so we can debug session failures from outside
          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = true;
              PermitRootLogin = "yes";
              UseDns = false;
            };
          };

          virtualisation.qemu.options = [
            # Disable the default VGA (-vga std) and use virtio-vga-gl instead.
            # This gives Hyprland a working DRM device via virgl (GL acceleration).
            "-vga none"
            "-device virtio-vga-gl"
            "-display gtk,gl=on,show-cursor=off"
          ];
        };
      };
    };
  };
}
