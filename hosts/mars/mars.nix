{ pkgs, nixvim, picom, ... }:
let
    home_dir = "/home/yokley";
    system = "x86_64-linux";
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
        pkgs.xbrightness
        nixvim.packages.${system}.default
    ];

    services.picom.package = picom.packages.${system}.default;
    home.stateVersion = "24.05"; # Don't touch me!

}
