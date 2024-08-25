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
  };

  outputs = { nixpkgs, home-manager, picom, ... }:
  {
    homeConfigurations = {
      "dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home.nix ./hosts/dioxygen.nix ];
      };

      "mercury" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
          ./hosts/mercury/home.nix
          {
            # home.packages = [ picom.packages.x86_64-linux.default ];
            services.picom.package = picom.packages.x86_64-linux.default;
            # services.picom
          }
        ];
      };

      "docker@dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [ ./home.nix ];
      };

      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ./hosts/venus.nix ];
      };

      "almagest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ./hosts/almagest.nix ];
      };
      "jupiter" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ./hosts/jupiter.nix ];
      };
      "saturn" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ./hosts/saturn.nix ];
      };
      "singularity" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ./hosts/singularity.nix ];
      };
    };
  };
}
