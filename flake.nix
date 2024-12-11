{
  description = "Home Manager configuration of yokley";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:kyokley/nixvim";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, ... }:
  let
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      mars = nixpkgs.lib.nixosSystem {
        modules = [
          ./programs/nixos/common-configuration.nix
          ./hosts/mars/configuration.nix
          ./hosts/mars/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.yokley = import ./hosts/mars/mars.nix;
            home-manager.extraSpecialArgs = { inherit nixvim; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      mercury = nixpkgs.lib.nixosSystem {
        modules = [
          ./programs/nixos/common-configuration.nix
          ./hosts/mercury/configuration.nix
          ./hosts/mercury/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.yokley = import ./hosts/mercury/mercury.nix;
            home-manager.extraSpecialArgs = { inherit nixvim; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      "saturn" = nixpkgs.lib.nixosSystem {
        modules = [
          ./programs/nixos/common-configuration.nix
            ./hosts/saturn/configuration.nix
            ./hosts/saturn/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.yokley = import ./hosts/saturn/saturn.nix;
              home-manager.extraSpecialArgs = { inherit nixvim; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
        ];
      };
    };

    homeConfigurations = {
      "dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${aarch64_darwin};
        modules = [
          ./hosts/dioxygen/dioxygen.nix
          {
            home.packages = [
              nixvim.packages.${aarch64_darwin}.default
            ];
          }
        ];
      };

      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        modules = [
          ./hosts/venus.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.minimal
            ];
          }
        ];
      };

      "almagest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        modules = [
          ./hosts/almagest.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.minimal
            ];
          }
        ];
      };
      "jupiter" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        modules = [
          ./hosts/jupiter.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.default
            ];
          }
        ];
      };
      "singularity" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        modules = [
          ./hosts/singularity.nix
          {
            home.packages = [
              nixvim.packages.${x86_linux}.minimal
            ];
          }
        ];
      };
      "titan" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${x86_linux};
        modules = [
          ./hosts/titan.nix
        ];
      };
    };
  };
}
