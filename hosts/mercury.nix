{ pkgs, ... }:
{
    imports = [
        ../programs/terminator.nix
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

  services.dunst = {
    enable = true;
    configFile = ../programs/dunst/dunstrc;
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

  programs.rofi.enable = true;
  programs.rofi.extraConfig = {
      modi = "drun,combi,run";
      show-icons = true;
      combi-modi = "drun,run";
      kb-cancel = "Escape,Control+c,Control+bracketleft";
      drun-match-fields = "name";
  };
  programs.rofi.theme = ../programs/qtile-config/rofi/fancy.rasi;
}
