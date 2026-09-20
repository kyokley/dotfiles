{
  flake.modules.homeManager.common = {
    programs.mergiraf = {
      enable = true;
      enableJujutsuIntegration = true;
    };
  };
}
