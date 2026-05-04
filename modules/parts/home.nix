{inputs, ...}: {
  flake.modules.homeManager = {
    common = {
      pkgs,
      lib,
      username,
      nixvim-output,
      hostName,
      inputs,
      ...
    }: let
      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      homeDirectory = "/home/${username}";
    in {
      home = {
        sessionVariables = {
          NIXPKGS_ALLOW_UNFREE = 1;
        };

        inherit username;
        homeDirectory = lib.mkDefault homeDirectory;
      };

      nix = {
        package = lib.mkDefault pkgs.nix;
        settings.experimental-features = ["nix-command" "flakes"];
      };

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
        inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-output}
      ];

      home.shellAliases = {
        home-manager-switch = "home-manager switch --refresh --flake 'github:kyokley/dotfiles#${hostName}'";
        ls = "ls --color=auto";
      };

      programs = {
        home-manager.enable = false;
        nh = {
          enable = true;
          clean = {
            enable = true;
            dates = "weekly";
          };
          flake = lib.mkDefault homeDirectory;
        };
      };

      age = {
        secrets = {
          ollama-mattermost-bot-token = {
            file = ./secrets/ollama-mattermost-bot-token.age;
          };
        };
      };
    };
  };
}
