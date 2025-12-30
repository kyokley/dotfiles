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

  networking.hostName = "mars"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    protonvpn-gui
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

  nix.buildMachines = [
    {
      hostName = "192.168.50.31";
      sshUser = username;
      system = "x86_64-linux";
      protocol = "ssh";
      maxJobs = 3;
      speedFactor = 2;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
