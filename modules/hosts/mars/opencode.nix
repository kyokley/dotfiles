{
  flake.modules.homeManager."yokley@mars" = {pkgs, ...}: {
    programs.opencode = {
      extraPackages = [pkgs.uv];
      settings = {
        mcp = {
          "mv-mcp" = {
            enabled = false;
            type = "remote";
            url = "http://127.0.0.1:8089/mcp";
          };
        };
      };
    };
  };
}
