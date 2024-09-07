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
        ".config/nixos/common-configuration.nix" = {
            source = ../../programs/nixos/common-configuration.nix;
        };
    };
}
