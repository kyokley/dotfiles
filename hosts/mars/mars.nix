{pkgs, ...}: {
  imports = [
    ../../programs/nixos/nixos.nix
    ../../home.nix
    ../../misc/dev.nix
  ];

  programs.git.userEmail = "kyokley@mars";

  home.sessionVariables = {
    QTILE_NET_INTERFACE = "wlp1s0";
  };

  home.packages = [
    pkgs.brightnessctl
  ];

  home.stateVersion = "24.05"; # Don't touch me!
}
