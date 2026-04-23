{inputs, ...}: let
  _qtile = {
    pkgs,
    lib,
    ...
  }: let
    force-lock-screen = pkgs.writeShellScriptBin "force-lock-screen" ''
      PATH=$PATH:${lib.makeBinPath [pkgs.betterlockscreen]}
      ${pkgs.betterlockscreen}/bin/betterlockscreen --lock
    '';
  in {
    home.packages = [
      force-lock-screen
    ];
  };
in {
  flake.modules.homeManager = {
    mars = _qtile;
    mercury = _qtile;
  };
}
