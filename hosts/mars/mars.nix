{
  pkgs,
  lib,
  ...
}: let
  cd_paths = [
    "/home/yokley/workspace"
    "/home/yokley/workspace/neo-tariff"
  ];
in {
  imports = [
    ../../programs/nixos/nixos.nix
    ../../programs/nixos/wallpapers.nix
    ../../home.nix
    ../../misc/dev.nix
  ];

  programs.git.settings.user.email = "kyokley@mars";

  home.sessionVariables = {
    QTILE_NET_INTERFACE = "wlp1s0";
    CDPATH = lib.concatStringsSep ":" cd_paths;
  };

  home.packages = [
    pkgs.brightnessctl
    pkgs.mattermost-desktop
    pkgs.lutris
  ];

  home.stateVersion = "24.05"; # Don't touch me!
}
