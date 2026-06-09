{
  flake.modules.homeManager.mars = {pkgs, ...}: {
    programs.opencode = {
      extraPackages = [pkgs.uv];
      settings = {
        mcp = {
          "mv-mcp" = {
            enabled = true;
            type = "remote";
            url = "http://127.0.0.1:8089/mcp";
          };
        };
      };
    };
  };
}
