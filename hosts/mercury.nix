{ pkgs, ... }:
{
    home.homeDirectory = "/home/yokley";
    programs.git.userEmail = "kyokley@mercury";

    imports = [
        ../programs/terminator.nix
        ../programs/dunst/dunst.nix
        ../programs/rofi/rofi.nix
    ];

    home.packages = [
        pkgs.arandr
        pkgs.dunst
        pkgs.libreoffice
        pkgs.nitrogen
        pkgs.python311Packages.bpython
        pkgs.thunderbird

        (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

    ];

  home.file = {
    ".config/qtile" = {
      source = ../programs/qtile-config;
      target = ".config/qtile";
      recursive = true;
    };
  };

  services.blueman-applet.enable = true;
  services.betterlockscreen = {
    enable = true;
    arguments = ["-u ~/Pictures/wallpapers"];
  };
  services.network-manager-applet.enable = true;
  systemd.user.targets.tray = {
      Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
      };
  };

  programs.poetry.enable = true;
}
