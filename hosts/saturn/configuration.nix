{ pkgs, ... }:
{
  imports = [
      ../../programs/openconnect.nix
      ../../programs/nixos/laptop.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "saturn"; # Define your hostname.

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];

  networking.extraHosts = ''
    192.168.50.75 jupiter
  '';

  system.stateVersion = "24.05"; # Don't touch me!
}
