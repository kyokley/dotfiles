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
}
