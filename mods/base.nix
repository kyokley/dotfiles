top @ {
  config,
  withSystem,
  moduleWithSystem,
  inputs,
  ...
}: {
  debug = true;
  imports = [];
  flake = let
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
        ../hosts/${hostName}/home.nix
        inputs.agenix.homeManagerModules.default
        (config.perSystem.packages.${hostName} or {})
      ];
    });

    nixosConfigurationGenerator = {
      system ? x86_linux,
      nixvim-output ? "default",
      hostName,
      username ? defaultUsername,
    }: (inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        ../modules/nixos/programs/nixos/configuration.nix
        ../modules/nixos/programs/nixos/hardware-configuration.nix
        ../hosts/${hostName}/configuration.nix
        ../hosts/${hostName}/hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.${username} = inputs.nixpkgs.lib.mkMerge [../hosts/${hostName}/home.nix inputs.agenix.homeManagerModules.default];
          home-manager.extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
        }
      ];
    });
  in {
    nixosConfigurations = {
      mars = nixosConfigurationGenerator {
        hostName = "mars";
      };
      mercury = nixosConfigurationGenerator {
        hostName = "mercury";
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
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
