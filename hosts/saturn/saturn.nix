{
  pkgs,
  lib,
  ...
}: let
  qtile-one-screen = pkgs.writeShellScriptBin "qtile-one-screen" ''
    xrandr --output eDP-1 --mode 1920x1200 --pos 0x0 --rotate normal --output HDMI-1 --off --output DP-1 --off --output DP-2 --off --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off
  '';
  qtile-two-screen = pkgs.writeShellScriptBin "qtile-two-screen" ''
    xrandr --output eDP-1 --off --output HDMI-1 --off --output DP-1 --off --output DP-2 --off --output DP-1-1 --off --output DP-1-2 --mode 2560x1440 --pos 0x0 --rotate normal --output DP-1-3 --primary --mode 1920x1080 --pos 2560x360 --rotate normal
  '';
  qtile-three-screen = pkgs.writeShellScriptBin "qtile-three-screen" ''
    xrandr --output eDP-1 --primary --mode 1920x1200 --pos 1553x1440 --rotate normal --output HDMI-1 --off --output DP-1 --off --output DP-2 --off --output DP-1-1 --off --output DP-1-2 --mode 2560x1440 --pos 0x0 --rotate normal --output DP-1-3 --mode 1920x1080 --pos 2560x360 --rotate normal
  '';
  cd_paths = [
    "/home/yokley/workspace/compost/foyr"
    "/home/yokley/workspace/compost/tpmcore"
    "/home/yokley/workspace"
  ];
  helperbot-dir = "/home/yokley/workspace/helperbot";
  helperbot-script = pkgs.writeShellScriptBin "autohelperbot" ''
    PATH=$PATH:${lib.makeBinPath [pkgs.git]}
    cd ${helperbot-dir}
    ${pkgs.python312Packages.uv}/bin/uv run helperbot -ad 3000
  '';
in {
  imports = [
    ../../programs/nixos/nixos.nix
    ../../home.nix
    ../../misc/dev.nix
  ];

  home.packages = [
    pkgs.brightnessctl
    pkgs.scrot
    qtile-one-screen
    qtile-two-screen
    qtile-three-screen
    helperbot-script
    pkgs.rclone
    pkgs.opensc
    pkgs.yubico-piv-tool
  ];

  home.sessionVariables = {
    QTILE_NET_INTERFACE = "enp0s13f0u3u1";
    CDPATH = lib.concatStringsSep ":" cd_paths;
  };

  programs.git.userEmail = "kevin.yokley@oracle.com";

  home.stateVersion = "24.05"; # Don't touch me!

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "phxtpmdev17" = {
        host = "phxtpmdev17";
        hostname = "phxtpmdev17.snphxprshared1.gbucdsint02phx.oraclevcn.com";
        user = "kevin.yokley";
      };
    };
  };
}
