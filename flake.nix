{
  description = "Home Manager configuration of yokley";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    picom = {
      url = "github:yshui/picom/v12-rc2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:kyokley/nixvim";
    };
  };

  outputs = { nixpkgs, home-manager, picom, nixvim, ... }@all:
  let
    dioxygen_system = "aarch64-darwin";
    venus_system = "x86_64-linux";
    almagest_system = "x86_64-linux";
    jupiter_system = "x86_64-linux";
    saturn_system = "x86_64-linux";
    singularity_system = "x86_64-linux";
    titan_system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      mars = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./programs/nixos/common-configuration.nix
          ./hosts/mars/configuration.nix
          ./hosts/mars/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.yokley = import ./hosts/mars/mars.nix;
            home-manager.extraSpecialArgs = { inherit nixvim picom; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      mercury = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./programs/nixos/common-configuration.nix
          ./hosts/mercury/configuration.nix
          ./hosts/mercury/hardware-configuration.nix
          {
            home-manager.users.yokley = import ./hosts/mercury/mercury.nix;
            home-manager.extraSpecialArgs = { inherit nixvim picom; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };

    homeConfigurations = {
      "dioxygen" = home-manager.lib.homeManagerConfiguration {
        specialArgs = { inherit all; };
        pkgs = nixpkgs.legacyPackages.${dioxygen_system};
        modules = [
          ./hosts/dioxygen.nix
          {
            home.packages = [
              nixvim.packages.${dioxygen_system}.default
            ];
          }
        ];
      };

      # "docker@dioxygen" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = nixpkgs.legacyPackages.aarch64-linux;
      #   modules = [ ./home.nix ];
      # };

      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${venus_system};
        modules = [
          ./hosts/venus.nix
          {
            home.packages = [
              nixvim.packages.${venus_system}.minimal
            ];
          }
        ];
      };

      "almagest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${almagest_system};
        modules = [
          ./hosts/almagest.nix
          {
            home.packages = [
              nixvim.packages.${almagest_system}.minimal
            ];
          }
        ];
      };
      "jupiter" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${jupiter_system};
        modules = [
          ./hosts/jupiter.nix
          {
            home.packages = [
              nixvim.packages.${jupiter_system}.default
            ];
          }
        ];
      };
      "saturn" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${saturn_system};
        modules = [
          ./hosts/saturn.nix
          {
            home.packages = [
              nixvim.packages.${saturn_system}.dos
            ];
          }
        ];
      };
      "singularity" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${singularity_system};
        modules = [
          ./hosts/singularity.nix
          {
            home.packages = [
              nixvim.packages.${singularity_system}.minimal
            ];
          }
        ];
      };
      "titan" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${titan_system};
        modules = [
          ./hosts/titan.nix
        ];
      };
    };
  };
}
