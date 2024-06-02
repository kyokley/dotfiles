{
  description = "Home Manager configuration of yokley";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  {
    homeConfigurations = {
      "dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;

# Specify your home configuration modules here, for example,
# the path to your home.nix.
        modules = [ ./home.nix ];

# Optionally use extraSpecialArgs
# to pass through arguments to home.nix
      };
      "mercury" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

# Specify your home configuration modules here, for example,
# the path to your home.nix.
        modules = [ ./home.nix ./hosts/mercury.nix ];

# Optionally use extraSpecialArgs
# to pass through arguments to home.nix
      };
      "docker@dioxygen" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;

# Specify your home configuration modules here, for example,
# the path to your home.nix.
        modules = [ ./home.nix ];

# Optionally use extraSpecialArgs
# to pass through arguments to home.nix
      };
      "venus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

# Specify your home configuration modules here, for example,
# the path to your home.nix.
        modules = [ ./home.nix ./hosts/venus.nix ];

# Optionally use extraSpecialArgs
# to pass through arguments to home.nix
      };
    };
  };
}
