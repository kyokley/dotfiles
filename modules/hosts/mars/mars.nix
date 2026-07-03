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
      inputs,
      config,
      ...
    }: let
      cd_paths = [
        "/home/${username}/workspace"
      ];
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
        ];

        stateVersion = "24.05"; # Don't touch me!
      };
    };

    nixos.mars = {
      inputs,
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
        extraModulePackages = [];
        extraModprobeConfig = ''
          # Mediatek MT7921E can be unstable around suspend/resume with ASPM/CLC.
          options mt7921e disable_aspm=Y
          options mt7921e disable_clc=Y
        '';
      };

      powerManagement.enable = true;

      environment.systemPackages = with pkgs; [
        proton-vpn
        spotify
        steam-devices-udev-rules
      ];

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
        udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
        '';
        xserver.videoDrivers = ["amdgpu"];
      };

      security.pam.services.lightdm.enableGnomeKeyring = false;
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

      environment.etc."systemd/system-sleep/99-nm-resume-reconnect" = {
        mode = "0755";
        text = ''
          #!${pkgs.runtimeShell}
          if [ "$1" = "post" ]; then
            ${pkgs.coreutils}/bin/sleep 2
            state="$(${pkgs.networkmanager}/bin/nmcli -t -f GENERAL.STATE device show wlp1s0 2>/dev/null | ${pkgs.coreutils}/bin/cut -d: -f2 | ${pkgs.gawk}/bin/awk '{print $1}')"

            if [ "$state" != "100" ]; then
              ${pkgs.networkmanager}/bin/nmcli device disconnect wlp1s0 >/dev/null 2>&1 || true
              ${pkgs.coreutils}/bin/sleep 1
              ${pkgs.networkmanager}/bin/nmcli device connect wlp1s0 >/dev/null 2>&1 || true
            fi
          fi
        '';
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.graphics.enable32Bit = true;

      virtualisation.vmVariant = {
        # When building with `nh os build-vm` (or nixos-rebuild build-vm),
        # default to Hyprland instead of Qtile, and configure the virtual GPU
        # so Hyprland can actually render.
        services.displayManager.defaultSession = "hyprland-uwsm";

        virtualisation.qemu.options = [
          # Disable the default VGA (-vga std) and use virtio-vga-gl instead.
          # This gives Hyprland a working DRM device via virgl (GL acceleration).
          "-vga none"
          "-device virtio-vga-gl"
          "-display gtk,gl=on,show-cursor=off"
        ];

        environment.sessionVariables = {
          # virtio-gpu doesn't support hardware cursors
          WLR_NO_HARDWARE_CURSORS = "1";
          # Fall back to software rendering if virgl isn't available
          WLR_RENDERER_ALLOW_SOFTWARE = "1";
          # Allow aquamarine backend to start without KMS if needed
          AQ_NO_KMS_REQUIREMENT = "1";
        };

        # Hyprland crashes on NixOS if /usr/share/icons doesn't exist.
        # In a VM, this path may not be present by default.
        systemd.tmpfiles.rules = [
          "d /usr/share/icons 0755 root root -"
        ];
      };
    };
  };
}
