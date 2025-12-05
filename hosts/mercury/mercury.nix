{
  pkgs,
  nixvim,
  ...
}: {
  imports = [
    ../../programs/nixos/nixos.nix
    ../../home.nix
  ];

  programs.git.settings.user.email = "kyokley@mercury";

  home.sessionVariables = {
    QTILE_NET_INTERFACE = "enp14s0";
  };

  home.packages = [
    nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.mattermost-desktop
  ];

  home.stateVersion = "24.05"; # Don't touch me!
}
