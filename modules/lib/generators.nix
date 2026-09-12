{
  inputs,
  constants,
}: let
  inherit (constants) defaultUsername defaultEmail defaultFullName;
  inherit (constants.systems) x86_linux aarch64_darwin;
in {
  mkHomeConfiguration = {
    system ? x86_linux,
    nixvim-output ? "default",
    hostName,
    fullName ? defaultFullName,
    username ? defaultUsername,
    email ? defaultEmail,
  }:let
      specArgs = {inherit inputs fullName email username nixvim-output hostName;};
  in

    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      extraSpecialArgs = specArgs;
      modules = [
        inputs.self.modules.homeManager."${username}@${hostName}"
        inputs.self.modules.homeManager.common
      ];
    };

  mkDarwinConfiguration = {
    system ? aarch64_darwin,
    nixvim-output ? "default",
    hostName,
    fullName ? defaultFullName,
    username ? defaultUsername,
    email ? defaultEmail,
  }: let
      specArgs = {inherit inputs fullName email username nixvim-output hostName;};
  in
    inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = specArgs;
      modules = [
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            users.${username} = inputs.nixpkgs.lib.mkMerge [
              inputs.self.modules.homeManager."${username}@${hostName}"
              inputs.self.modules.homeManager.common
              inputs.self.modules.homeManager.darwin
            ];
            extraSpecialArgs = specArgs;
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
    fullName ? defaultFullName,
    username ? defaultUsername,
    email ? defaultEmail,
  }: let
      specArgs = {inherit inputs fullName email username nixvim-output hostName;};
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specArgs;
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sysc-greet.nixosModules.default
        {
          home-manager = {
            users.${username} = inputs.nixpkgs.lib.mkMerge [
              inputs.self.modules.homeManager."${username}@${hostName}"
              inputs.self.modules.homeManager.common
              inputs.self.modules.homeManager.nixos
            ];
            extraSpecialArgs = specArgs;
          };
        }
        inputs.self.modules.nixos.${hostName}
        inputs.self.modules.nixos.common
      ];
    };
}
