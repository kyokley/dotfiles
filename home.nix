{ pkgs, lib, ... }:

{
  imports = [
    ./programs/shell/zsh.nix
    ./programs/git/git.nix
    ./programs/tmux.nix
    ./programs/vim.nix
    ./programs/systemd.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.mkDefault "yokley";
  home.homeDirectory = lib.mkDefault "/home/yokley";

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  programs.systemd-services.enable = lib.mkDefault true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.fd
    pkgs.fzf
    pkgs.gnumake
    pkgs.ripgrep
    pkgs.ruff
    pkgs.bandit
    pkgs.tig
    pkgs.unzip
    pkgs.zsh
    pkgs.nix-search-cli
    pkgs.lftp
    pkgs.home-manager
  ];

  programs.home-manager.enable = false;
}
