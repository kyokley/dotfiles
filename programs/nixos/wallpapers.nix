{
  pkgs,
  username,
  ...
}: let
  homeDir = "/home/${username}";
  remoteWallpaperHost = "jupiter";
in {
  home.file.wallpapers = {
    enable = true;
    target = "Pictures/wallpapers/.keep";
    text = "";
  };

  systemd.user.services = {
    sync-wallpapers = {
      Unit.Description = "Sync wallpapers with upstream image repository";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "sync-wallpapers" ''
            set -x
            ${pkgs.rsync}/bin/rsync --timeout=10 --rsh="${pkgs.openssh}/bin/ssh -o 'StrictHostKeyChecking=no'" -ruv ${remoteWallpaperHost}:${homeDir}/Pictures/wallpapers ${homeDir}/Pictures/
            ${pkgs.rsync}/bin/rsync --timeout=10 --rsh="${pkgs.openssh}/bin/ssh -o 'StrictHostKeyChecking=no'" -ruv ${homeDir}/Pictures/wallpapers ${remoteWallpaperHost}:${homeDir}/Pictures/
          ''
        );
      };
    };
  };

  systemd.user.timers = {
    sync-wallpapers = {
      Unit = {
        Description = "Timer to trigger sync wallpapers";
        After = ["network.target"];
      };
      Timer = {
        OnCalendar = "*:0";
        Persistent = true;
        Unit = "sync-wallpapers.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
