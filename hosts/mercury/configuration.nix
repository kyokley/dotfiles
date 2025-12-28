{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../programs/tailscale.nix
    ./ssh.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "mercury"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ollama
    sshfs
  ];

  system.stateVersion = "24.05"; # Don't touch me!

  programs.fuse = {
    userAllowOther = true;
  };
}
