{ pkgs, lib, ... }:
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
    ".config/picom/picom-custom.conf" = {
      source = ./picom.conf;
    };
  };

  services.blueman-applet.enable = true;

  services.xidlehook = {
    enable = true;
    detect-sleep = true;
    not-when-fullscreen = true;
    timers = [
      {
        delay = 250;
        command = "${pkgs.dunst}/bin/dunstify '' 'Locking screen in 10 secs' -t 10";
      }
      {
        delay = 10;
        command = "${pkgs.betterlockscreen}/bin/betterlockscreen --lock";
      }
    ];
  };


  services.network-manager-applet.enable = true;
  systemd.user.targets.tray = {
      Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
      };
  };

  systemd.user.services = {
      update-lockscreen = {
          Unit.Description = "Update lockscreen background image";
          Service = {
              Type = "oneshot";
              ExecStart = toString (
                      pkgs.writeShellScript "betterlockscreen-update-script" ''
                      PATH=$PATH:${lib.makeBinPath [ pkgs.nix pkgs.coreutils pkgs.busybox pkgs.xorg.xrdb ]}
                      ${pkgs.betterlockscreen}/bin/betterlockscreen -u /home/yokley/Pictures/wallpapers --fx ""
                      ''
                      );
          };
      };
  };

  systemd.user.timers = {
      update-lockscreen = {
          Unit = {
              Description = "Update betterlockscreen";
              After = [ "network.target" ];
          };
          Timer = {
              OnCalendar = "*-*-* *:0/5:00";
              Persistent = true;
              Unit = "update-lockscreen.service";
          };
          Install.WantedBy = ["timers.target"];
      };
  };

  services = {
    picom = {
        enable = true;
        extraArgs = [ "--config=/home/yokley/.config/picom/picom-custom.conf" ];
    };
  };

  programs.poetry.enable = true;
}
