{
  pkgs,
  lib,
  ...
} @ inputs: {
  imports = [
    ./programs/shell/zsh.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/vim.nix
    ./programs/systemd.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.mkDefault "${inputs.username}";
  home.homeDirectory = lib.mkDefault "/home/${inputs.username}";

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  programs.systemd-services.enable = lib.mkDefault true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.fd
    pkgs.fzf
    pkgs.unzip
    pkgs.zsh
    pkgs.nix-search-cli
    pkgs.lftp
    pkgs.home-manager
  ];

  home.shellAliases = {
    home-manager-switch = "home-manager switch --refresh --flake 'git+ssh://git@venus.ftpaccess.cc:10022/kyokley/dotfiles.git?ref=main#${inputs.hostname}'";
    ls = "ls --color=auto";
  };

  programs.home-manager.enable = false;
}
