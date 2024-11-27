{ pkgs, ... }:
{
  imports = [
      ../../programs/openconnect/no-proxy.nix
      ../../programs/nixos/laptop.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Not sure if these are needed to fix docker networking issues when tailscale
  # exit nodes are active
  # boot.kernel.sysctl = {
  #   "net.ipv4.ip_forward" = true;
  #   "net.ipv6.conf.all.forwarding" = true;
  # };

  networking.hostName = "mars"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    gnome-keyring
  ];

  system.stateVersion = "24.05"; # Don't touch me!
}
