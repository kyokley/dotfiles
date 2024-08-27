{
  description = "Home Manager configuration of yokley";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    picom = {
      url = "github:yshui/picom/v12-rc2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:kyokley/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, picom, nixvim, ... }:
  let
    dioxygen_system = "aarch64-darwin";
    mercury_system = "x86_64-linux";
    venus_system = "x86_64-linux";
    almagest_system = "x86_64-linux";
    jupiter_system = "x86_64-linux";
    saturn_system = "x86_64-linux";
    singularity_system = "x86_64-linux";
  in
  {
    homeConfigurations = {
      "dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${dioxygen_system};
        modules = [
          ./home.nix
          ./hosts/dioxygen.nix
          {
            home.packages = [
              nixvim.packages.${dioxygen_system}.default
            ];
          }
        ];
      };

      "mercury" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${mercury_system};
        modules = [
          ./home.nix
          ./hosts/mercury/home.nix
          {
            home.packages = [
              nixvim.packages.${mercury_system}.default
            ];
            services.picom.package = picom.packages.${mercury_system}.default;
          }
        ];
      };

      "docker@dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [ ./home.nix ];
      };

      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${venus_system};
        modules = [
          ./home.nix
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
          ./home.nix
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
          ./home.nix
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
          ./home.nix
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
          ./home.nix
          ./hosts/singularity.nix
          {
            home.packages = [
              nixvim.packages.${singularity_system}.minimal
            ];
          }
        ];
      };
    };
  };
}
