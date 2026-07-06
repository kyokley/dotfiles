{
  description = "Nix system configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:kyokley/nixvim";
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

    fastfetch-config = {
      url = "github:kyokley/fastfetch-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # Prevents version mismatch.
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {
      inherit inputs;
    }
    (_: let
      constants = import ./modules/lib/constants.nix;
      generators = import ./modules/lib/generators.nix {
        inherit inputs constants;
      };
    in {
      systems = [
        constants.systems.x86_linux
        constants.systems.aarch64_darwin
      ];
      _module.args = {
        inherit constants generators;
      };
      imports = [
        inputs.home-manager.flakeModules.home-manager
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules/parts)
        (inputs.import-tree ./modules/hosts)
      ];
    });
}
