{inputs, ...}: {
  flake.modules.homeManager.agenix = {pkgs, ...}: {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];

    home.packages = [
      pkgs.ragenix
    ];
  };
}
