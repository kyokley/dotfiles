{pkgs, ...}: let
  homeDir = "/home/yokley";
in {
  systemd.user.services = {
    update-login-background = {
      Unit.Description = "Update login screen image";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "login-screen-update-script" ''
            ln -sf $(find ${homeDir}/Pictures -name '*.jpg' | shuf | head -n 1) ${homeDir}/Pictures/login.jpg
          ''
        );
      };
    };
  };

  systemd.user.timers = {
    update-login-background = {
      Unit = {
        Description = "Update login screen";
        After = ["network.target"];
      };
      Timer = {
        OnCalendar = "*-*-* *:0/5:00";
        Persistent = true;
        Unit = "update-login-background.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
