let
  _ai = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: {
    imports = [
      ./opencode.nix
    ];

    home = {
      packages = [
        pkgs.github-copilot-cli
      ];
    };
  };
in {
  flake.modules.homeManager = {
    mars = _ai;
    mercury = _ai;
  };
}
