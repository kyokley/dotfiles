{ pkgs, nixvim, ... }:
let
    qtile-one-screen = pkgs.writeShellScriptBin "qtile-one-screen" ''
        xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal --output HDMI-1 --off --output DP-1 --off --output DP-2 --off
    '';
    qtile-two-screen = pkgs.writeShellScriptBin "qtile-two-screen" ''
        xrandr --output eDP-1 --off --output HDMI-1 --primary --mode 1920x1080 --pos 2560x360 --rotate normal --output DP-1 --mode 2560x1440 --pos 0x0 --rotate normal --output DP-2 --off
    '';
    qtile-three-screen = pkgs.writeShellScriptBin "qtile-three-screen" ''
        xrandr --output HDMI-1 --mode 1920x1080 --pos 2560x360 --rotate normal --output eDP-1 --primary --mode 1920x1200 --pos 1608x1440 --rotate normal --output DP-1 --mode 2560x1440 --pos 0x0 --rotate normal --output DP-2 --off
    '';
in
{

    imports = [
        ../../programs/nixos/nixos.nix
        ../../home.nix
    ];

    home.packages = [
        pkgs.devenv
        pkgs.brightnessctl
        pkgs.scrot
        nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
        qtile-one-screen
        qtile-two-screen
        qtile-three-screen
        pkgs.rclone
        pkgs.opensc
        pkgs.yubico-piv-tool
    ];

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "wlp113s0f0";
        CDPATH = "/home/yokley/workspace/compost/tpmcore";
    };

    programs.git.userEmail = "kevin.yokley@oracle.com";

    home.stateVersion = "24.05"; # Don't touch me!
}
