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

  system.stateVersion = "24.05"; # Don't touch me!

  programs.fuse = {
    userAllowOther = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ollama
    sshfs
  ];

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "100.92.134.123";
    loadModels = [
      "llama3.2:3b"
      "gpt-oss"
      "qwen3:8b"
      "qwen3-coder:30b"
      "gemma3:12b"
    ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    11434
  ];
}
