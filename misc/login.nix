{pkgs, ...}: let
  background_dir = "/usr/share/backgrounds";
in {
  services.xserver.displayManager.lightdm = {
    background = "${background_dir}/login.jpg";
    greeters.enso = {
      enable = true;
    };
  };

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
          cp -fv $(${pkgs.busybox}/bin/find ${background_dir}/wallpapers -name '*.jpg' | ${pkgs.busybox}/bin/shuf | ${pkgs.busybox}/bin/head -n 1) ${background_dir}/login.jpg
          chmod 755 ${background_dir}/login.jpg
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
}
