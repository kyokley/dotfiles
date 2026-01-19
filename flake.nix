{
  description = "Nix system configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    username = "yokley";
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";
    defaultSpecialArgs = {
      system,
      nixvim-output ? "default",
      hostName,
    }: {
      pkgs-unstable = import inputs.nixpkgs-unstable {
        config.allowUnfree = true;
        inherit system;
      };
      inherit hostName;
      inherit username;
      inherit nixvim-output;
      inherit (inputs) qtile-flake nixvim usql ollama-mattermost-bot;
    };

    homeManagerConfigurationGenerator = spec: (inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${spec.system};
      extraSpecialArgs =
        defaultSpecialArgs spec;
      modules = [
        ./hosts/${spec.hostName}/home.nix
        inputs.agenix.homeManagerModules.default
      ];
    });
    nixosConfigurationGenerator = spec: (inputs.nixpkgs.lib.nixosSystem {
      specialArgs =
        defaultSpecialArgs spec;
      modules = [
        ./modules/nixos/programs/nixos/configuration.nix
        ./modules/nixos/programs/nixos/hardware-configuration.nix
        ./hosts/${spec.hostName}/configuration.nix
        ./hosts/${spec.hostName}/hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.${username} = inputs.nixpkgs.lib.mkMerge [./hosts/${spec.hostName}/home.nix inputs.agenix.homeManagerModules.default];
          home-manager.extraSpecialArgs =
            defaultSpecialArgs spec;
        }
      ];
    });
  in {
    nixosConfigurations = {
      mars = nixosConfigurationGenerator {
        hostName = "mars";
        system = x86_linux;
        nixvim-output = "withAider";
      };
      mercury = nixosConfigurationGenerator {
        hostName = "mercury";
        system = x86_linux;
      };
    };

    homeConfigurations = {
      dioxygen = homeManagerConfigurationGenerator {
        system = aarch64_darwin;
        hostName = "dioxygen";
      };

      venus = homeManagerConfigurationGenerator {
        system = x86_linux;
        hostName = "venus";
        nixvim-output = "minimal";
      };

      almagest = homeManagerConfigurationGenerator {
        system = x86_linux;
        hostName = "almagest";
      };
      jupiter = homeManagerConfigurationGenerator {
        system = x86_linux;
        hostName = "jupiter";
      };
      singularity = homeManagerConfigurationGenerator {
        system = x86_linux;
        hostName = "singularity";
        nixvim-output = "minimal";
      };
    };
  };
}
