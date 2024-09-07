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
        ".config/nixos/common-configuration.nix" = {
            source = ../../programs/nixos/common-configuration.nix;
        };
    };
}
