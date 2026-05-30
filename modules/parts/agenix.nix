{inputs, ...}: {
  flake.modules.homeManager.common = {pkgs, ...}: {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];

    home.packages = [
      pkgs.ragenix
    ];

    age = {
      secrets = {
        mars-syncthing-key = {
          file = ./_secrets/syncthing/mars/key.age;
        };
      };
    };
  };
}
