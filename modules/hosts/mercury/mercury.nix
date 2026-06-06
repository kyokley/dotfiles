{inputs, ...}: {
  flake.modules = let
    home_imports = with inputs.self.modules.homeManager; [
      opencode
      systemd-services
      syncthing
      dev
    ];

    nixos_imports = with inputs.self.modules.nixos; [
      tailscale
    ];
  in {
    homeManager.mercury = {
      pkgs,
      config,
      username,
      inputs,
      ...
    }: let
      MATTERMOST_CLEANUP_RETENTION_WINDOW = "30 days";
    in {
      imports = home_imports;
      programs.git.settings.user.email = "kyokley@mercury";

      home = {
        sessionVariables = {
          QTILE_NET_INTERFACE = "enp14s0";
        };

        packages = [
          pkgs.mattermost-desktop
        ];

        stateVersion = "24.05"; # Don't touch me!
      };

      systemd.user.services = {
        mattermost-clean-old-posts = {
          Unit.Description = "Remove old posts from mattermost";
          Service = {
            Type = "oneshot";
            ExecStart = toString (
              pkgs.writeShellScript "mattermost-clean-old-posts" ''
                cd /home/${username}/workspace/mattermost
                ${pkgs.docker}/bin/docker compose exec postgres17 psql -U mmuser -d mattermost -c "
                  begin;
                  delete from posts where createat < extract(epoch from (now() - interval '${MATTERMOST_CLEANUP_RETENTION_WINDOW}'))::int8 * 1000;
                  delete from reactions where postid not in (select id from posts);
                  delete from fileinfo where postid not in (select id from posts);
                  commit;
                  "
              ''
            );
          };
        };
      };

      systemd.user.timers = {
        mattermost-daily-task = {
          Unit = {
            Description = "Run tasks daily";
            After = ["network.target"];
          };
          Timer = {
            OnCalendar = "daily";
            RandomizedDelaySec = 14400;
            Persistent = true;
            Unit = "mattermost-clean-old-posts.service";
          };
          Install.WantedBy = ["timers.target"];
        };
      };
    };

    nixos.mercury = {
      inputs,
      pkgs,
      config,
      lib,
      modulesPath,
      ...
    }: {
      imports =
        [
          (modulesPath + "/installer/scan/not-detected.nix")
        ]
        ++ nixos_imports;

      # Bootloader.
      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        supportedFilesystems = ["bcachefs"];
        kernelPackages = pkgs.linuxPackages_latest;
        binfmt.emulatedSystems = [
          "aarch64-linux"
        ];
        initrd = {
          availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
          kernelModules = ["amdgpu"];
        };
        kernelModules = ["kvm-amd" "amdgpu"];
        extraModulePackages = [];
      };

      system.stateVersion = "24.05"; # Don't touch me!

      programs.fuse = {
        userAllowOther = true;
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        sshfs
      ];

      fileSystems = {
        "/" = {
          device = "UUID=75f8e791-7457-4ae2-b6a1-dbcda9aed60b";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/764D-E9E8";
          fsType = "vfat";
          options = ["fmask=0777" "dmask=0777"];
        };
      };

      swapDevices = [];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.interfaces.enp14s0.useDHCP = lib.mkDefault true;
      # networking.interfaces.wlp15s0.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
