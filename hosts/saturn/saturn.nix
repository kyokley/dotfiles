{ pkgs, nixvim, picom, ... }:
let
    home_dir = "/home/yokley";
in
{

    imports = [
        ../../programs/nixos/nixos.nix
        ../../home.nix
    ];

    programs.systemd-services.environment = "saturn";

    home.packages = [
        pkgs.devenv
        pkgs.brightnessctl
        pkgs.scrot
        nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "wlp113s0f0";
    };

    home.homeDirectory = "${home_dir}";
    programs.git.userEmail = "kevin.yokley@oracle.com";

    services.picom.package = picom.packages.${pkgs.stdenv.hostPlatform.system}.default;

    home.stateVersion = "24.05"; # Don't touch me!
}
