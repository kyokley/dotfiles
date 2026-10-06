{
  flake.modules.homeManager.common = {
    programs.mergiraf = {
      enable = true;
      enableJujutsuIntegration = false;
      enableGitIntegration = false;
    };
  };
}
