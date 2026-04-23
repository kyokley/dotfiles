{
  pkgs,
  lib,
  username,
  ...
}: let
  cd_paths = [
    "/home/${username}/workspace"
  ];
in {
  imports = [
    ../../modules/home-manager/programs/nixos/nixos.nix
    ../../modules/home-manager/programs/nixos/wallpapers.nix
    ../../modules/home-manager/home.nix
    ../../modules/home-manager/ai/ai.nix
  ];

  programs.git.settings.user.email = "kyokley@mars";

  home = {
    sessionVariables = {
      QTILE_NET_INTERFACE = "wlp1s0";
      CDPATH = lib.concatStringsSep ":" cd_paths;
    };

    packages = [
      pkgs.ollama
      pkgs.brightnessctl
      pkgs.mattermost-desktop
      pkgs.lutris
      pkgs.steam
    ];

    stateVersion = "24.05"; # Don't touch me!
  };
}
