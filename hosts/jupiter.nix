{pkgs, lib, ...}:
{
  home.packages = [
    pkgs.pass
    pkgs.borgbackup
  ];

  programs.systemd-services.environment = "jupiter";

  systemd.user.services = {
      mediawaiter-daily-tasks = {
          Unit.Description = "Run tasks daily";
          Service = {
              Type = "oneshot";
              ExecStart = toString (
                  pkgs.writeShellScript "mediawaiter-daily-tasks" ''
                  ${pkgs.rsync}/bin/rsync -av --rsh=ssh --delete yokley@almagest.dyndns.org:/home/yokley/workspace/MediaViewerProd/backups /home/yokley/db_backups 2>&1 > /home/yokley/db_backup.log
              ''
              );
          };
      };
      mediawaiter-weekly-tasks = {
          Unit.Description = "Run tasks weekly";
          Service = {
              Type = "oneshot";
              ExecStart = toString (
                  pkgs.writeShellScript "mediawaiter-weekly-tasks" ''
                  ${pkgs.bash}/bin/bash /mnt/external/backup.sh 2>&1 > /home/yokley/file_backup.log
              ''
              );
          };
      };
  };

  systemd.user.timers = {
    mediawaiter-daily-tasks = {
      Unit = {
        Description = "Run tasks daily";
        After = [ "network.target" ];
      };
      Timer = {
        OnCalendar = "daily";
        RandomizedDelaySec = 14400;
        Persistent = true;
        Unit = "mediawaiter-daily-tasks.service";
      };
      Install.WantedBy = ["timers.target"];
    };
    mediawaiter-weekly-tasks = {
      Unit = {
        Description = "Run tasks weekly";
        After = [ "network.target" ];
      };
      Timer = {
        OnCalendar = "weekly";
        RandomizedDelaySec = 14400;
        Persistent = true;
        Unit = "mediawaiter-weekly-tasks.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  programs = {
    nixvim.enable = false;

    git.userEmail = "kyokley@jupiter";

    borgmatic = {
      enable = true;
      backups = {
        mediawaiter = {
          location = {
            sourceDirectories = [
              "/mnt/hd"
              "/mnt/hd2"
            ];
            repositories = [ "ssh://u415868@u415868.your-storagebox.de:23/./mw-repo" ];
          };
          storage = {
            encryptionPasscommand = "${pkgs.pass}/bin/pass borg/mediawaiter";
          };
        };
      };
    };

    zsh.prezto.extraConfig = lib.mkAfter
          ''
          function mc-run() {
              cd ~/workspace/MediaConverterProd
              make run
              cd -
          }
          '';
  };

  systemd.user.services = {
    borg-update = {
      Unit.Description = "Create borg backup";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
            pkgs.writeShellScript "borg-update-script" ''
            PATH=$PATH:${lib.makeBinPath [ pkgs.nix pkgs.coreutils pkgs.busybox ]}
            ${pkgs.borgbackup}/bin/borgmatic create --stats
            ''
            );
      };
    };
  };

  systemd.user.timers = {
      borg-update = {
          Unit = {
              Description = "Update borg backup";
              After = [ "network.target" ];
          };
          Timer = {
              OnCalendar = "*-*-* 2:00:00";
              RandomizedDelaySec = 3600;
              Persistent = true;
              Unit = "borg-update.service";
          };
          Install.WantedBy = ["timers.target"];
      };
  };
}
