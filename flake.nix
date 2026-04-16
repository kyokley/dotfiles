{
  description = "Nix system configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    less-nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

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
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
  };

  outputs = inputs: let
    defaultUsername = "yokley";
    aarch64_darwin = "aarch64-darwin";
    x86_linux = "x86_64-linux";

    homeManagerConfigurationGenerator = {
      system ? x86_linux,
      nixvim-output ? "default",
      hostName,
      username ? defaultUsername,
    }: (inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        ./hosts/${hostName}/home.nix
        inputs.agenix.homeManagerModules.default
      ];
    });

    nixosConfigurationGenerator = {
      system ? x86_linux,
      nixvim-output ? "default",
      hostName,
      username ? defaultUsername,
      additionalModules ? [],
    }: (inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs username nixvim-output hostName;};
      modules =
        [
          ./modules/nixos/programs/nixos/configuration.nix
          ./modules/nixos/programs/nixos/hardware-configuration.nix
          ./hosts/${hostName}/configuration.nix
          ./hosts/${hostName}/hardware-configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = inputs.nixpkgs.lib.mkMerge [./hosts/${hostName}/home.nix inputs.agenix.homeManagerModules.default];
            home-manager.extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
          }
        ]
        ++ additionalModules;
    });

    den =
      (inputs.nixpkgs.lib.evalModules {
        modules = [
          (inputs.import-tree ./mods)
          inputs.den.flakeModule
        ];
        specialArgs.inputs = inputs;
      }).config;

    inherit (den.den.hosts.x86_64-linux) mars mercury;
  in {
    nixosConfigurations = {
      mars = nixosConfigurationGenerator {
        hostName = "mars";
        additionalModules = [mars.mainModule];
      };
      mercury = nixosConfigurationGenerator {
        hostName = "mercury";
        additionalModules = [mercury.mainModule];
      };
    };

    homeConfigurations = {
      dioxygen = homeManagerConfigurationGenerator {
        system = aarch64_darwin;
        hostName = "dioxygen";
      };

      venus = homeManagerConfigurationGenerator {
        hostName = "venus";
        nixvim-output = "minimal";
      };

      almagest = homeManagerConfigurationGenerator {
        hostName = "almagest";
        nixvim-output = "withoutCopilot";
      };
      jupiter = homeManagerConfigurationGenerator {
        hostName = "jupiter";
      };
      singularity = homeManagerConfigurationGenerator {
        hostName = "singularity";
        nixvim-output = "minimal";
      };
    };
  };
}
