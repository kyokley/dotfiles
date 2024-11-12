{ pkgs, nixvim, picom, ... }:
let
    home_dir = "/home/yokley";
in
{
    imports = [
        ../../programs/nixos/nixos.nix
        ../../home.nix
    ];

    programs.systemd-services.environment = "mercury";

    home.homeDirectory = "${home_dir}";
    programs.git.userEmail = "kyokley@mercury";

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "enp14s0";
    };

    home.packages = [
        nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    services.picom.package = picom.packages.${pkgs.stdenv.hostPlatform.system}.default;

    home.stateVersion = "24.05"; # Don't touch me!
}
