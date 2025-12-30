{
  pkgs,
  lib,
  ...
} @ inputs: let
  cd_paths = [
    "/home/${inputs.username}/workspace"
  ];
in {
  imports = [
    ../../modules/home-manager/programs/nixos/nixos.nix
    ../../modules/home-manager/programs/nixos/wallpapers.nix
    ../../modules/home-manager/home.nix
    ../../modules/home-manager/dev.nix
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
