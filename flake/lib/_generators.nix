{
  inputs,
  constants,
}: let
  inherit (constants) defaultUsername;
  inherit (constants.systems) x86_linux;
in {
  mkHomeConfiguration = {
    system ? x86_linux,
    nixvim-output ? "default",
    hostName,
    username ? defaultUsername,
    extraModules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        ../../hosts/${hostName}/home.nix
        inputs.agenix.homeManagerModules.default
        inputs.self.modules.homeManager.${hostName}
        inputs.self.modules.homeManager.common
      ];
    };

  mkNixosConfiguration = {
    system ? x86_linux,
    nixvim-output ? "default",
    hostName,
    username ? defaultUsername,
    extraModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        ../../modules/nixos/programs/nixos/configuration.nix
        ../../modules/nixos/programs/nixos/hardware-configuration.nix
        ../../hosts/${hostName}/configuration.nix
        ../../hosts/${hostName}/hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.${username} = inputs.nixpkgs.lib.mkMerge [
            ../../hosts/${hostName}/home.nix
            inputs.agenix.homeManagerModules.default
            inputs.self.modules.homeManager.${hostName}
            inputs.self.modules.homeManager.common
          ];
          home-manager.extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
        }
        inputs.self.modules.nixos.${hostName}
      ];
    };
}
