{
  pkgs,
  nixvim,
  ...
}: {
  imports = [
    ../../programs/nixos/nixos.nix
    ../../home.nix
  ];

  programs.git.settings.user.email = "kyokley@mercury";

  home.sessionVariables = {
    QTILE_NET_INTERFACE = "enp14s0";
  };

  home.packages = [
    nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.mattermost-desktop
  ];

  home.stateVersion = "24.05"; # Don't touch me!

  systemd.user.services = {
    mattermost-clean-old-posts = {
      Unit.Description = "Remove old posts from mattermost";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "mattermost-clean-old-posts" ''
            cd /home/yokley/workspace/mattermost
            ${pkgs.docker}/bin/docker compose exec postgres17 psql -U mmuser -d mattermost -c "
              begin;
              delete from posts where createat < extract(epoch from (now() - interval '7 days'))::int8 * 1000;
              delete from reactions where postid not in (select id from posts);
              delete from fileinfo where postid not in (select id from posts);
              rollback;
              "
          ''
        );
      };
    };
  };

  systemd.user.timers = {
    mattermost-daily-task = {
      Unit = {
        Description = "Run tasks daily";
        After = ["network.target"];
      };
      Timer = {
        OnCalendar = "daily";
        RandomizedDelaySec = 14400;
        Persistent = true;
        Unit = "mattermost-clean-old-posts.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
