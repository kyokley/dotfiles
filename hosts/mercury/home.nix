{ pkgs, ... }:
{
    programs.systemd-services.environment = "mercury";

    home.homeDirectory = "/home/yokley";
    programs.git.userEmail = "kyokley@mercury";

    imports = [
        ../../programs/terminator.nix
        ../../programs/dunst/dunst.nix
        ../../programs/rofi/rofi.nix
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
      source = ../../programs/qtile;
      target = ".config/qtile";
      recursive = true;
    };
    ".config/nixos/configuration.nix" = {
      source = ./configuration.nix;
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

  services = {
    picom = {
      enable = true;
      fade = true;
      settings = {
        animations = [
        {
          triggers = ["close" "hide"];
          opacity = {
            curve = "linear";
            duration = 0.11;
            start = "window-raw-opacity-before";
            end = 0;
          };
          blur-opacity = "opacity";
          shadow-opacity = "opacity";
        }
        {
          triggers = ["open" "show"];
          opacity = {
            curve = "cubic-bezier(0,1,1,1)";
            duration = 0.3;
            start = 0;
            end = "window-raw-opacity";
          };
          blur-opacity = "opacity";
          shadow-opacity = "opacity";
          offset-x = "(1 - scale-x) / 2 * window-width";
          offset-y = "(1 - scale-y) / 2 * window-height";
          scale-x = {
            curve = "cubic-bezier(0,1.3,1,1)";
            duration = 0.3;
            start = 0.6;
            end = 1;
          };
          scale-y = "scale-x";
          shadow-scale-x = "scale-x";
          shadow-scale-y = "scale-y";
          shadow-offset-x = "offset-x";
          shadow-offset-y = "offset-y";
        }
        {
          triggers = ["geometry"];
          scale-x = {
            curve = "cubic-bezier(0,0,0,1.28)";
            duration = 0.22;
            start = "window-width-before / window-width";
            end = 1;
          };
          scale-y = {
            curve = "cubic-bezier(0,0,0,1.28)";
            duration = 0.22;
            start = "window-height-before / window-height";
            end = 1;
          };
          offset-x = {
            curve = "cubic-bezier(0,0,0,1.28)";
            duration = 0.22;
            start = "window-x-before - window-x";
            end = 0;
          };
          offset-y = {
            curve = "cubic-bezier(0,0,0,1.28)";
            duration = 0.22;
            start = "window-y-before - window-y";
            end = 0;
          };
          shadow-scale-x = "scale-x";
          shadow-scale-y = "scale-y";
          shadow-offset-x = "offset-x";
          shadow-offset-y = "offset-y";
        }
        ];
      };
    };
  };

  programs.poetry.enable = true;
}
