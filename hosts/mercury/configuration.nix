{
  pkgs,
  config,
  lib,
  ...
}: {
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
    ollama-rocm
    sshfs
  ];

  # Ollama server setup
  services.ollama = {
    enable = true;
    host = "100.92.134.123";
    loadModels = [
      "llama3.2:3b"
      "gpt-oss"
      "qwen3:8b"
      "qwen3-coder:30b"
      "gemma3:12b"
      "deepseek-r1:32b"
    ];
    environmentVariables = {
      ROCR_VISIBLE_DEVICES = "1";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkIf config.services.ollama.enable [
    11434
  ];
}
