{ config, pkgs, ... }:
{
    imports = [
        ../programs/terminator.nix
    ];

    home.packages = [
        pkgs.zsh
            pkgs.ripgrep
            pkgs.unzip
            pkgs.thunderbird
            pkgs.python311Packages.bpython
            pkgs.ruff
            pkgs.arandr
            pkgs.nitrogen
            pkgs.tig
            pkgs.dunst
            pkgs.gnumake
            pkgs.fzf
            pkgs.libreoffice

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
    configFile = "${config.home.homeDirectory}/dotfiles/dunst/dunstrc";
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
}
