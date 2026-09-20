{
  flake.module.homeManager.delta = {
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          line-numbers = true;
        };
      };
    };
  };
}
