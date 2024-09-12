{
    programs.systemd-services.environment = "mercury";

    home.homeDirectory = "/home/yokley";
    programs.git.userEmail = "kyokley@mercury";

    imports = [
        ../../programs/nixos/nixos.nix
    ];

    home.file = {
        ".config/nixos/configuration.nix" = {
            source = ./configuration.nix;
        };
    };

    home.sessionVariables = {
        QTILE_NET_INTERFACE = "enp14s0";
        NIXPKGS_ALLOW_UNFREE = "1";
    };
}
