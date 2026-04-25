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
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.${username} = inputs.nixpkgs.lib.mkMerge [
            inputs.self.modules.homeManager.${hostName}
            inputs.self.modules.homeManager.common
            inputs.self.modules.homeManager.nixos
          ];
          home-manager.extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
        }
        inputs.self.modules.nixos.${hostName}
        inputs.self.modules.nixos.common
      ];
    };
}
