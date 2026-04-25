{inputs, ...}: {
  flake.modules.homeManager.common = {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];
  };
}
