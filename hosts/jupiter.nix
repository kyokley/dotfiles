{pkgs, lib, ...}:
{
  home.packages = [
    pkgs.pass
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
        test = {
          location = {
            sourceDirectories = [ "/tmp/foo" ];
            repositories = [ "ssh://u415868@u415868.your-storagebox.de:23/./test-repo" ];
          };
          storage = {
            encryptionPasscommand = "${pkgs.pass}/bin/pass Backup/hetzner.com";
          };
        };
        # mediawaiter = {
        #   location = {
        #     sourceDirectories = [ "/tmp/foo" ];
        #     repositories = [ "ssh://u415868@u415868.your-storagebox.de/./mw-repo" ];
        #   };
        # };
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
}
