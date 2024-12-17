{ pkgs, lib, extraSpecialArgs, ... }:

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
    pkgs.tig
    pkgs.unzip
    pkgs.zsh
    pkgs.nix-search-cli
    pkgs.lftp
    pkgs.home-manager
    pkgs.jq
    pkgs.zsh-wd
  ];

  home.shellAliases = {
    home-manager-switch = "home-manager switch --flake 'git+ssh://git@venus.ftpaccess.cc:10022/kyokley/dotfiles.git?ref=main#${extraSpecialArgs.userConf.vars.hostname}'";
    home-manager-test = "home-manager test --flake 'git+ssh://git@venus.ftpaccess.cc:10022/kyokley/dotfiles.git?ref=main#${extraSpecialArgs.userConf.vars.hostname}'";
  };

  programs.home-manager.enable = false;
}
