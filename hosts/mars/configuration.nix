{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/nixos/programs/tailscale.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/login.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  environment.systemPackages = with pkgs; [
    protonvpn-gui
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

  virtualisation.vmVariant = {
    users = {
      users.${username}.password = "password";
      extraUsers.root.password = "password";
    };
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    networking.firewall.allowedTCPPorts = [22];
    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
      # desktopManager.default = "none";
    };
    virtualisation = {
      memorySize = 4096;
      cores = 3;
      qemu.options = ["-device virtio-vga-gl" "-display gtk,gl=on"];
      sharedDirectories = {
        share = {
          source = "/usr/share/backgrounds";
          target = "/usr/share/backgrounds";
        };
      };
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };
  };

  networking.extraHosts = ''
    192.168.50.126 saturn # ethernet
    192.168.50.96 saturn-wifi # wifi
  '';

  services.xserver.videoDrivers = ["amdgpu"];
}
