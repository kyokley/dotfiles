{ pkgs, lib, ... }:
let
  mv_path = "/home/yokley/workspace/MediaViewerProd";
in
{
  home.packages = [
    pkgs.docker-compose
  ];

  programs.systemd-services.environment = "almagest";
  systemd.user.services = {
      mediaviewer-daily-tasks = {
          Unit.Description = "Run tasks daily";
          Service = {
              Type = "oneshot";
              ExecStart = toString (
                  pkgs.writeShellScript "mediaviewer-daily-tasks" ''
                  PATH=$PATH:${lib.makeBinPath [ pkgs.nix ]}
                  cd ${mv_path}
                  TTY=-T ${pkgs.gnumake}/bin/make backup-db
                  TTY=-T ${pkgs.gnumake}/bin/make expiretokens
              ''
              );
          };
      };
      mediaviewer-monthly-tasks = {
          Unit.Description = "Run tasks monthly";
          Service = {
              Type = "oneshot";
              ExecStart = toString (
                  pkgs.writeShellScript "mediaviewer-monthly-tasks" ''
                  PATH=$PATH:${lib.makeBinPath [ pkgs.nix ]}
                  cd ${mv_path}
                  TTY=-T ${pkgs.gnumake}/bin/make clear-sessions
              ''
              );
          };
      };
  };

  systemd.user.timers = {
    mediaviewer-daily-tasks = {
      Unit = {
        Description = "Run tasks daily";
        After = [ "network.target" ];
      };
      Timer = {
        OnCalendar = "daily";
        RandomizedDelaySec = 14400;
        Persistent = true;
        Unit = "mediaviewer-daily-tasks.service";
      };
      Install.WantedBy = ["timers.target"];
    };
    mediaviewer-monthly-tasks = {
      Unit = {
        Description = "Run tasks monthly";
        After = [ "network.target" ];
      };
      Timer = {
        OnCalendar = "monthly";
        RandomizedDelaySec = 14400;
        Persistent = true;
        Unit = "mediaviewer-monthly-tasks.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  programs.nixvim.enable = false;
  programs.nixvim.installType = "minimal";

  programs.git.userEmail = "kyokley@almagest";
}
