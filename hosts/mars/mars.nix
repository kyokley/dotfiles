{ pkgs, nixvim, ... }:
let
    home_dir = "/home/yokley";
in
{
    imports = [
        ../../programs/nixos/nixos.nix
        ../../home.nix
    ];

    programs.systemd-services.environment = "mars";

    home.homeDirectory = "${home_dir}";
    programs.git.userEmail = "kyokley@mars";

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "wlp1s0";
    };

    home.packages = [
        pkgs.devenv
        pkgs.brightnessctl
        nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.stateVersion = "24.05"; # Don't touch me!

}
