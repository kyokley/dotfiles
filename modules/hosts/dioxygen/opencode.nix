{
  flake.modules.homeManager."yokley@dioxygen" = {pkgs, ...}: {
    programs.opencode = {
      extraPackages = [pkgs.uv];
    };
  };
}
