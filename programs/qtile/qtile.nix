{
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
}
