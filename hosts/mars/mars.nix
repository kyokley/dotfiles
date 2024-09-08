{ pkgs, ... }:
let
    home_dir = "/home/yokley";
in
{
    imports = [
        ../../programs/nixos/nixos.nix
    ];

    programs.systemd-services.environment = "mars";

    home.homeDirectory = "${home_dir}";
    programs.git.userEmail = "kyokley@mars";

    home.file = {
        ".config/nixos/configuration.nix" = {
            source = ./configuration.nix;
        };
    };

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "wlp1s0";
        QTILE_BAT_PATH = "/sys/class/power_supply/BAT1";
        NIXPKGS_ALLOW_UNFREE = "1";
    };

    home.packages = [
        pkgs.xbrightness
        pkgs.spotify
    ];
}
