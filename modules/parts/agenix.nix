{inputs, ...}: {
  flake.modules.homeManager.common = {pkgs, ...}: {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];

    home.packages = [
      pkgs.ragenix
    ];
  };
}
