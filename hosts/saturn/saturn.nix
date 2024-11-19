{ pkgs, lib, ... }:
{
    programs.systemd-services.enable = false;

    imports = [
      ../home.nix
    ];

    home.packages = [
        pkgs.devenv
        pkgs.xfce.thunar
        pkgs.xsel
        pkgs.python311Packages.bpython
    ];

    programs.git.userEmail = "kevin.yokley@oracle.com";
    home.stateVersion = "23.11"; # Please read the comment before changing.
}
