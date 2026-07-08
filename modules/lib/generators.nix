{
  inputs,
  constants,
}: let
  inherit (constants) defaultUsername;
  inherit (constants.systems) x86_linux aarch64_darwin;
in {
  mkHomeConfiguration = {
    system ? x86_linux,
    nixvim-output ? "default",
    hostName,
    username ? defaultUsername,
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        inputs.self.modules.homeManager."${username}@${hostName}"
        inputs.self.modules.homeManager.common
      ];
    };

  mkDarwinConfiguration = {
    system ? aarch64_darwin,
    nixvim-output ? "default",
    hostName,
    username ? defaultUsername,
  }: inputs.darwin.lib.darwinSystem {
    inherit system;
    specialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            users.${username} = inputs.nixpkgs.lib.mkMerge [
              inputs.self.modules.homeManager."${username}@${hostName}"
              inputs.self.modules.homeManager.common
              inputs.self.modules.homeManager.darwin
            ];
            extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
          };
        }
        inputs.self.modules.darwin.${hostName}
        inputs.self.modules.darwin.common
        ];
  };

  mkNixosConfiguration = {
    system ? x86_linux,
    nixvim-output ? "default",
    hostName,
    username ? defaultUsername,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs username nixvim-output hostName;};
      modules = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            users.${username} = inputs.nixpkgs.lib.mkMerge [
              inputs.self.modules.homeManager."${username}@${hostName}"
              inputs.self.modules.homeManager.common
              inputs.self.modules.homeManager.nixos
            ];
            extraSpecialArgs = {inherit inputs username nixvim-output hostName;};
          };
        }
        inputs.self.modules.nixos.${hostName}
        inputs.self.modules.nixos.common
      ];
    };
}
