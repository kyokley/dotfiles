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
    };
  in {
    nixosConfigurations = {
      mars = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          defaultSpecialArgs x86_linux;
        modules = [
          ./modules/nixos/programs/nixos/configuration.nix
          ./modules/nixos/programs/nixos/hardware-configuration.nix
          ./hosts/mars/configuration.nix
          ./hosts/mars/hardware-configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = import ./hosts/mars/home.nix;
            home-manager.extraSpecialArgs =
              (defaultSpecialArgs x86_linux)
              // {
                hostname = "mars";
              };
          }
        ];
      };
      mercury = inputs.nixpkgs.lib.nixosSystem {
        specialArgs =
          defaultSpecialArgs x86_linux;
        modules = [
          ./modules/nixos/programs/nixos/configuration.nix
          ./modules/nixos/programs/nixos/hardware-configuration.nix
          ./hosts/mercury/configuration.nix
          ./hosts/mercury/hardware-configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = import ./hosts/mercury/home.nix;
            home-manager.extraSpecialArgs =
              (defaultSpecialArgs x86_linux)
              // {
                hostname = "mercury";
              };
          }
        ];
      };
    };

    homeConfigurations = {
      "dioxygen" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${aarch64_darwin};
        extraSpecialArgs =
          (defaultSpecialArgs aarch64_darwin)
          // {
            hostname = "dioxygen";
          };
        modules = [
          ./hosts/dioxygen/home.nix
        ];
      };

      "venus" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "venus";
          };
        modules = [
          ./hosts/venus/home.nix
        ];
      };

      "almagest" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "almagest";
          };
        modules = [
          ./hosts/almagest/home.nix
        ];
      };
      "jupiter" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "jupiter";
          };
        modules = [
          ./hosts/jupiter/home.nix
        ];
      };
      "singularity" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "singularity";
          };
        modules = [
          ./hosts/singularity/home.nix
        ];
      };
    };
  };
}
