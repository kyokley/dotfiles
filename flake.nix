{
  description = "Home Manager configuration of yokley";

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
      url = "github:qtile/qtile/v0.33.0";
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
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";
  in {
    nixosConfigurations = {
      mars = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = x86_linux;
          };
        };
        modules = [
          (_: {nixpkgs.overlays = [qtile-flake.overlays.default];})
          ./programs/nixos/common-configuration.nix
          ./programs/nixos/hardware-configuration.nix
          ./hosts/mars/configuration.nix
          ./hosts/mars/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.yokley = import ./hosts/mars/mars.nix;
            home-manager.extraSpecialArgs = {
              vars = import ./hosts/mars/vars.nix;
              inherit nixvim;
              inherit usql;
              pkgs-unstable = import nixpkgs-unstable {
                config.allowUnfree = true;
                system = x86_linux;
              };
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      mercury = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = x86_linux;
          };
        };
        modules = [
          (_: {nixpkgs.overlays = [qtile-flake.overlays.default];})
          ./programs/nixos/common-configuration.nix
          ./programs/nixos/hardware-configuration.nix
          ./hosts/mercury/configuration.nix
          ./hosts/mercury/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.yokley = import ./hosts/mercury/mercury.nix;
            home-manager.extraSpecialArgs = {
              vars = import ./hosts/mercury/vars.nix;
              inherit nixvim;
              pkgs-unstable = import nixpkgs-unstable {
                config.allowUnfree = true;
                system = x86_linux;
              };
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
        extraSpecialArgs = {
          vars = import ./hosts/dioxygen/vars.nix;
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = aarch64_darwin;
          };
          inherit nixvim;
          inherit usql;
        };
        modules = [
          ./hosts/dioxygen/dioxygen.nix
        ];
      };

      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs = {
          vars = import ./hosts/venus/vars.nix;
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = x86_linux;
          };
        };
        modules = [
          ./hosts/venus/venus.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.minimal
            ];
          }
        ];
      };

      "almagest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs = {
          vars = import ./hosts/almagest/vars.nix;
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = x86_linux;
          };
        };
        modules = [
          ./hosts/almagest/almagest.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.minimal
            ];
          }
        ];
      };
      "jupiter" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs = {
          vars = import ./hosts/jupiter/vars.nix;
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = x86_linux;
          };
        };
        modules = [
          ./hosts/jupiter/jupiter.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.default
            ];
          }
        ];
      };
      "singularity" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        extraSpecialArgs = {
          vars = import ./hosts/singularity/vars.nix;
          pkgs-unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            system = x86_linux;
          };
        };
        modules = [
          ./hosts/singularity/singularity.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.minimal
            ];
          }
        ];
      };
    };
  };
}
