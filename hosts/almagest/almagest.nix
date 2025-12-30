{
  pkgs,
  lib,
  nixvim,
  username,
  ...
}: let
  mv_path = "/home/${username}/workspace/MediaViewerProd";
in {
  imports = [
    ../../modules/home-manager/home.nix
  ];

  home.packages = [
    pkgs.docker-compose
    nixvim.packages.${pkgs.stdenv.hostPlatform.system}.minimal
  ];

  systemd.user.services = {
    mediaviewer-daily-tasks = {
      Unit.Description = "Run tasks daily";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "mediaviewer-daily-tasks" ''
            PATH=$PATH:${lib.makeBinPath [pkgs.nix]}
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
            PATH=$PATH:${lib.makeBinPath [pkgs.nix]}
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
        After = ["network.target"];
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
        After = ["network.target"];
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

  programs = {
    git.settings.user.email = "kyokley@almagest";
  };

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
