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
    nix-oracle-db.url = "github:kyokley/nix-oracle-db/gvenzl";
  };

  outputs = {...} @ inputs: let
    username = "yokley";
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";
    defaultSpecialArgs = system: {
      pkgs-unstable = import inputs.nixpkgs-unstable {
        config.allowUnfree = true;
        inherit system;
      };
      inherit username;
      qtile-flake = inputs.qtile-flake;
      nixvim = inputs.nixvim;
      usql = inputs.usql;
      nix-oracle-db = inputs.nix-oracle-db;
    };

    homeManagerConfigurationGenerator = spec: (inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${spec.system};
      extraSpecialArgs =
        (defaultSpecialArgs spec.system)
        // {
          hostname = spec.hostName;
        };
      modules = [
        ./hosts/${spec.hostName}/home.nix
      ];
    });
    nixosConfigurationGenerator = spec: (inputs.nixpkgs.lib.nixosSystem {
      specialArgs =
        defaultSpecialArgs spec.system;
      modules = [
        ./modules/nixos/programs/nixos/configuration.nix
        ./modules/nixos/programs/nixos/hardware-configuration.nix
        ./hosts/${spec.hostName}/configuration.nix
        ./hosts/${spec.hostName}/hardware-configuration.nix
        inputs.nix-oracle-db.nixosModules.oracle-database-container
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.${username} = import ./hosts/${spec.hostName}/home.nix;
          home-manager.extraSpecialArgs =
            (defaultSpecialArgs spec.system)
            // {
              hostname = spec.hostName;
            };
        }
      ];
    });
  in {
    nixosConfigurations = {
      mars = nixosConfigurationGenerator {
        hostName = "mars";
        system = x86_linux;
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
      };
    };
  };
}
