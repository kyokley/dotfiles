{
  flake.modules = {
    homeManager.mars = {
      pkgs,
      lib,
      username,
      inputs,
      ...
    }: let
      cd_paths = [
        "/home/${username}/workspace"
      ];
    in {
      imports = with inputs.self.modules.homeManager; [
        dev
        distributedBuilds
        wallpapers
        systemd-services
      ];

      programs.git.settings.user.email = "kyokley@mars";

      home = {
        sessionVariables = {
          QTILE_NET_INTERFACE = "wlp1s0";
          CDPATH = lib.concatStringsSep ":" cd_paths;
        };

        packages = [
          pkgs.ollama
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
      imports = [
        inputs.self.modules.nixos.laptop
        inputs.self.modules.nixos.distributedBuilds
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
      };

      powerManagement.enable = true;
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
      '';

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

      networking.extraHosts = ''
        192.168.50.126 saturn # ethernet
        192.168.50.96 saturn-wifi # wifi
      '';

      services.xserver.videoDrivers = ["amdgpu"];

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

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

      nixpkgs.overlays = [
        (final: prev: {
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = false;
          });
          libreoffice = prev.libreoffice.overrideAttrs (_: {
            doCheck = false;
          });
        })
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.graphics.enable32Bit = true;
    };
  };
}
