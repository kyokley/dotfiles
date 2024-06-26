{ pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.mkDefault "yokley";
  home.homeDirectory = lib.mkDefault "/home/yokley";

  imports = [
    ./programs/shell/zsh.nix
    ./programs/git/git.nix
    ./programs/tmux.nix
    ./programs/vim.nix
    ./programs/systemd.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.fd
    pkgs.fzf
    pkgs.gnumake
    pkgs.ripgrep
    pkgs.ruff
    pkgs.tig
    pkgs.unzip
    pkgs.zsh
  ];

  programs.nixvim.enable = lib.mkDefault true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  services.home-manager.autoUpgrade = {
    enable = lib.mkDefault true;
    frequency = "weekly";
  };
}
