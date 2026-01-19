{pkgs, config, ...} @ inputs: {
  imports = [
    ../../modules/home-manager/programs/nixos/nixos.nix
    ../../modules/home-manager/home.nix
    ../../modules/home-manager/ai.nix
  ];

  programs.git.settings.user.email = "kyokley@mercury";

  home.sessionVariables = {
    QTILE_NET_INTERFACE = "enp14s0";
  };

  home.packages = [
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
            cd /home/${inputs.username}/workspace/mattermost
            ${pkgs.docker}/bin/docker compose exec postgres17 psql -U mmuser -d mattermost -c "
              begin;
              delete from posts where createat < extract(epoch from (now() - interval '7 days'))::int8 * 1000;
              delete from reactions where postid not in (select id from posts);
              delete from fileinfo where postid not in (select id from posts);
              commit;
              "
          ''
        );
      };
    };

    ollama-mattermost-bot = {
      Unit.Description = "Run Ollama Chatbot for Mattermost";
      Service = {
        ExecStart = toString (
          pkgs.writeShellScript "run-mattermost-bot" ''
            ${inputs.ollama-mattermost-bot.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/ollama-mattermost-bot
          ''
        );
        RuntimeMaxSec = 86400;
        Environment = [
          "MATTERMOST_URL=mercury.taila5201.ts.net"
          "BOT_TOKEN_PATH=${config.age.secrets.ollama-mattermost-bot-token.path}"
          "TEAM_NAME=Mercury"

          "OLLAMA_API_URL=http://100.92.134.123:11434"
          "OLLAMA_MODEL=llama3.2:3b"
        ];
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

    ollama-mattermost-bot-daily-task = {
      Unit = {
        Description = "Run tasks daily";
        After = ["network.target"];
      };
      Timer = {
        OnCalendar = "daily";
        RandomizedDelaySec = 14400;
        Persistent = true;
        Unit = "ollama-mattermost-bot.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
