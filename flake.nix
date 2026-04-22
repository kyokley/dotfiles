{
  description = "Nix system configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:kyokley/nixvim";
    };

    usql = {
      url = "github:kyokley/psql-pager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ollama-mattermost-bot = {
      url = "github:kyokley/ollama-mattermost-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-config = {
      url = "github:kyokley/opencode-config";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {
      inherit inputs;
    }
    ({...}: let
      constants = import ./flake/lib/constants.nix;
      generators = import ./flake/lib/generators.nix {
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
        ./flake/parts/tree.nix
      ];
    });
}
