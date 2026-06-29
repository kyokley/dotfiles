{
  flake.modules.homeManager = {
    common = {
      pkgs,
      lib,
      username,
      nixvim-output,
      inputs,
      config,
      ...
    }: let
      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      homeDirectory = "/home/${username}";
    in {
      nix = {
        package = lib.mkDefault pkgs.nix;
        settings = {
          experimental-features = ["nix-command" "flakes"];
        };
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      };

      nixpkgs = {
        overlays = [
          (final: prev: {
            openldap = prev.openldap.overrideAttrs (_: {
              doCheck = false;
            });
            libreoffice = prev.libreoffice.overrideAttrs (_: {
              doCheck = false;
            });
          })
        ];
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            # Add additional package names here
            "github-copilot-cli"
            "steam"
            "steam-unwrapped"
          ];
      };

      home = {
        sessionVariables = {
          NIXPKGS_ALLOW_UNFREE = 1;
          PYTHONDONTWRITEBYTECODE = 1;
        };

        inherit username;
        homeDirectory = lib.mkDefault homeDirectory;

        packages = [
          pkgs.fd
          pkgs.fzf
          pkgs.unzip
          pkgs.zsh
          pkgs.nix
          pkgs.nix-search-cli
          pkgs.lftp
          pkgs.home-manager
          inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-output}
        ];

        shellAliases = {
          home-manager-switch = "nh home switch";
          ls = "ls --color=auto";
        };
      };

      programs = {
        home-manager.enable = false;
        nh = {
          enable = true;
          clean = {
            enable = true;
            dates = "weekly";
          };
          flake = lib.mkDefault "${config.home.homeDirectory}/dotfiles";
        };
        zoxide = {
          enable = true;
          enableZshIntegration = true;
          options = [
            "--cmd cd"
          ];
        };
      };
    };
  };
}
