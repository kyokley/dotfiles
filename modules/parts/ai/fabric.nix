let
  _fabric = {
    programs = {
      fabric-ai = {
        enable = true;
        enablePatternsAliases = false;
        enableYtAlias = true;
        enableZshIntegration = true;
      };

      yt-dlp.enable = true;
    };
  };
in {
  flake.modules.homeManager = {
    mars = _fabric;
    mercury = _fabric;
  };
}
