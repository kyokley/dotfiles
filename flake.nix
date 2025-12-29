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

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nixvim,
    qtile-flake,
    usql,
    ...
  }: let
    username = "yokley";
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";
    defaultSpecialArgs = system: {
      pkgs-unstable = import nixpkgs-unstable {
        config.allowUnfree = true;
        inherit system;
      };
      inherit username;
      qtile-flake = qtile-flake.packages.${x86_linux};
    };
  in {
    nixosConfigurations = {
      mars = nixpkgs.lib.nixosSystem {
        specialArgs =
          defaultSpecialArgs x86_linux;
        modules = [
          ./programs/nixos/common-configuration.nix
          ./programs/nixos/hardware-configuration.nix
          ./hosts/mars/configuration.nix
          ./hosts/mars/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = import ./hosts/mars/mars.nix;
            home-manager.extraSpecialArgs =
              (defaultSpecialArgs x86_linux)
              // {
                hostname = "mars";
                inherit nixvim;
                inherit usql;
              };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      mercury = nixpkgs.lib.nixosSystem {
        specialArgs =
          defaultSpecialArgs x86_linux;
        modules = [
          ./programs/nixos/common-configuration.nix
          ./programs/nixos/hardware-configuration.nix
          ./hosts/mercury/configuration.nix
          ./hosts/mercury/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = import ./hosts/mercury/mercury.nix;
            home-manager.extraSpecialArgs =
              (defaultSpecialArgs x86_linux)
              // {
                hostname = "mercury";
                inherit nixvim;
              };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };

    homeConfigurations = {
      "dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${aarch64_darwin};
        extraSpecialArgs =
          (defaultSpecialArgs aarch64_darwin)
          // {
            hostname = "dioxygen";
            inherit nixvim;
            inherit usql;
          };
        modules = [
          ./hosts/dioxygen/dioxygen.nix
        ];
      };

      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "venus";
          };
        modules = [
          ./hosts/venus/venus.nix
        ];
      };

      "almagest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "almagest";
            inherit nixvim;
          };
        modules = [
          ./hosts/almagest/almagest.nix
        ];
      };
      "jupiter" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "jupiter";
            inherit nixvim;
          };
        modules = [
          ./hosts/jupiter/jupiter.nix
        ];
      };
      "singularity" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs =
          (defaultSpecialArgs x86_linux)
          // {
            hostname = "singularity";
            inherit nixvim;
          };
        modules = [
          ./hosts/singularity/singularity.nix
        ];
      };
    };
  };
}
