{
  flake.modules.homeManager."yokley@mars" = {pkgs, ...}: {
    programs.opencode = {
      extraPackages = [pkgs.uv];
    };
  };
}
