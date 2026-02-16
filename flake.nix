{
  description = "Nix system configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:kyokley/nixvim";
    };
    qtile-flake = {
      url = "github:qtile/qtile/v0.34.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    usql = {
      url = "github:kyokley/psql-pager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ollama-mattermost-bot = {
      url = "github:kyokley/ollama-mattermost-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aider-commit = {
      url = "github:kyokley/aider-commit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    defaultUsername = "yokley";
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";

    homeManagerConfigurationGenerator = {
      system ? x86_linux,
      nixvim-output ? "default",
      hostName,
      username ? defaultUsername,
    }: (inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        ./hosts/${hostName}/home.nix
        inputs.agenix.homeManagerModules.default
      ];
    });

    nixosConfigurationGenerator = {
      system ? x86_linux,
      nixvim-output ? "default",
      hostName,
      username ? defaultUsername,
    }: (inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        ./modules/nixos/programs/nixos/configuration.nix
        ./modules/nixos/programs/nixos/hardware-configuration.nix
        ./hosts/${hostName}/configuration.nix
        ./hosts/${hostName}/hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.${username} = inputs.nixpkgs.lib.mkMerge [./hosts/${hostName}/home.nix inputs.agenix.homeManagerModules.default];
          home-manager.extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
        }
      ];
    });
  in {
    nixosConfigurations = {
      mars = nixosConfigurationGenerator {
        hostName = "mars";
      };
      mercury = nixosConfigurationGenerator {
        hostName = "mercury";
      };

      dioxygen-vm = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = let
          pkgs = import inputs.nixpkgs {
            system = "aarch64-linux";
          };
          inherit (inputs.nixpkgs) lib;
          username = "yokley";
        in [
          inputs.home-manager.nixosModules.home-manager
          {
            fileSystems."/".device = "/dev/vdb1";
            boot.loader.grub.devices = ["/dev/vdb1"];
            nixpkgs.hostPlatform = {system = "aarch64-linux";};
            system.stateVersion = "26.05"; # Don't touch me!
            users.users.${username} = {
              shell = pkgs.zsh;
              isNormalUser = true;
              description = "Kevin Yokley";
              extraGroups = [
                "networkmanager"
                "wheel"
                "docker"
                "vboxusers"
              ];
            };
            programs.zsh.enable = true;
            home-manager.users.${username} = {
              nix = {
                package = lib.mkDefault pkgs.nix;
                settings.experimental-features = ["nix-command" "flakes"];
              };
              home = {
                packages = with pkgs; [
                  devenv
                  direnv
                ];
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "26.05";
              };
            };
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };
    };

    homeConfigurations = {
      dioxygen = homeManagerConfigurationGenerator {
        system = aarch64_darwin;
        hostName = "dioxygen";
      };

      venus = homeManagerConfigurationGenerator {
        hostName = "venus";
        nixvim-output = "minimal";
      };

      almagest = homeManagerConfigurationGenerator {
        hostName = "almagest";
        nixvim-output = "withoutAider";
      };
      jupiter = homeManagerConfigurationGenerator {
        hostName = "jupiter";
      };
      singularity = homeManagerConfigurationGenerator {
        hostName = "singularity";
        nixvim-output = "minimal";
      };
    };
  };
}
