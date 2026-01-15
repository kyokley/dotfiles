{pkgs, ...}: {
  imports = [
    ../../modules/nixos/programs/tailscale.nix
    ./ssh.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

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
