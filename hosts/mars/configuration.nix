{ pkgs, ... }:
{
  imports = [
      ../../programs/openconnect/no-proxy.nix
      ../../programs/tailscale.nix
      ../../programs/nixos/laptop.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "mars"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    gnome-keyring
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
    192.168.50.96 saturn
  '';
}
