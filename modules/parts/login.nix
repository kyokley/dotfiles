{
  flake.modules.nixos.common = {pkgs, ...}: let
    background_file = "/etc/login/login.jpg";
    wallpapers_dir = "/home/yokley/Pictures/wallpapers";
  in {
    services.xserver.displayManager.lightdm = {
      background = "${background_file}";
      # Temporarily switching to slick greeter as enso fails
      greeters.slick = {
        enable = true;
      };
    };

    environment.etc."login/login.jpg".source = ./qtile/wallpapers/wallpaper.jpg;

    systemd.services = {
      update-login-background = {
        enable = true;
        description = "Update login screen image";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        script = toString (
          pkgs.writeShellScript "login-screen-update-script" ''

            cp -fv $(${pkgs.busybox}/bin/find ${wallpapers_dir} -name '*.jpg' | ${pkgs.busybox}/bin/shuf | ${pkgs.busybox}/bin/head -n 1) ${background_file}
            chmod 755 ${background_file}
          ''
        );
        wants = ["network-online.target"];
        after = ["network-online.target"];
        wantedBy = ["multi-user.target"];
      };
    };

    systemd.timers = {
      update-login-background = {
        timerConfig = {
          OnBootSec = "5m";
          OnUnitActiveSec = "5m";
          Unit = "update-login-background.service";
        };
        wantedBy = ["timers.target"];
      };
    };

    programs.dconf.enable = true;
  };
}
