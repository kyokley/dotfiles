{ nixvim, ... }:
{
    imports = [
        ../../programs/nixos/nixos.nix
        ../../home.nix
    ];

    programs.systemd-services.environment = "mercury";

    programs.git.userEmail = "kyokley@mercury";

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "enp14s0";
    };

    home.packages = [
        nixvim.packages.${builtins.currentSystem}.default
    ];

    home.stateVersion = "24.05"; # Don't touch me!
}
