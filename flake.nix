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
  };

  outputs = {...} @ inputs: let
    defaultUsername = "yokley";
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";

    homeManagerConfigurationGenerator = {
      system ? x86_linux,
      nixvim-output ? "default",
      hostName,
      username ? defaultUsername,
    }: (inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
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
        nixvim-output = "withAider";
      };
      mercury = nixosConfigurationGenerator {
        hostName = "mercury";
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
