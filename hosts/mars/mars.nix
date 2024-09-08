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
    };

    home.packages = [
        pkgs.xbrightness
    ];
}
