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
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${inputs.nixvim-output}
  ];

  home.shellAliases = {
    home-manager-switch = "home-manager switch --refresh --flake 'github:kyokley/dotfiles#${inputs.hostName}'";
    ls = "ls --color=auto";
  };

  programs.home-manager.enable = false;

  nix.buildMachines = [
    {
      hostName = "192.168.50.31";
      sshUser = inputs.username;
      systems = ["x86_64-linux"];
      protocol = "ssh";
      maxJobs = 3;
      speedFactor = 2;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  age = {
    identityPaths = ["~/.ssh/id_ed25519"];
    secrets = {
      ollama-mattermost-bot-token = {
        file = ../../secrets/ollama-mattermost-bot-token.age;
      };
    };
  };
}
