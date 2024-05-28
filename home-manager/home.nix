{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yokley";
  home.homeDirectory = "/Users/yokley";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.zsh
    pkgs.ripgrep
    pkgs.unzip
    pkgs.ruff
    pkgs.tig
    pkgs.gnumake
    pkgs.fzf

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/yokley/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.shellAliases = {
    vim = "nix run github:kyokley/nixvim --";
  };

  # programs.terminator = {
  #   enable = true;
  #   config = {
  #     profiles.default.font = "Hack Nerd Font Mono 16";
  #     profiles.default.use_system_font = false;
  #     profiles.default.scrollback_infinite = true;
  #     profiles.demo.font = "Hack Nerd Font Mono 25";
  #     profiles.demo.use_system_font = false;
  #   };
  # };
  programs.poetry.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    prezto = {
      enable = true;
      caseSensitive = false;
      prompt.theme = "powerlevel10k";
      extraConfig = (builtins.concatStringsSep "\n" [
        (builtins.readFile ./powerlevel10k_config.zsh)
        ''
        function init-psql() {
            touch $HOME/.psql_history

            mkdir -p $HOME/.config/pgcli
            touch $HOME/.config/pgcli/history
            touch $HOME/.pgpass
            touch $HOME/.pg_service.conf
        }

        function psql() {
            init-psql
            docker run \
                --rm -it \
                --net=host \
                -e "PGTZ=America/Chicago" \
                -e "PSQL_HISTORY=/root/.psql_history" \
                -v "$HOME/.psql_history:/root/.psql_history" \
                -v "/tmp:/tmp" \
                -v "$(pwd):/workspace" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                -v "$HOME/.pg_service.conf:/root/.pg_service.conf" \
                kyokley/psql \
                "$@"
        }

        function pgcli() {
            init-psql
            mkdir -p "$HOME/.config/pgcli"
            touch "$HOME/.config/pgcli/history"
            docker run \
                --rm -it \
                --net=host \
                -e UID="$(id | grep -Eo 'uid=\\d+' | tail -c +5)" \
                -e GID="$(id | grep -Eo 'gid=\\d+' | tail -c +5)" \
                -e "PGTZ=America/Chicago" \
                -v "$HOME/.config/pgcli/history:/root/.config/pgcli/history" \
                -v "/tmp:/tmp" \
                -v "$(pwd):/workspace" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                -v "$HOME/.pg_service.conf:/root/.pg_service.conf" \
                kyokley/pgcli \
                "$@"
        }

        function pg-shell() {
            init-psql
            docker run \
                --rm -it \
                --net=host \
                -e "PGTZ=America/Chicago" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                -v $(pwd):/workspace \
                --entrypoint "sh" \
                kyokley/psql \
                "$@"
        }

        function pg_dump() {
            init-psql
            docker run \
                --rm -it \
                --net=host \
                -e "PGTZ=America/Chicago" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                -v $(pwd):/workspace \
                --entrypoint "pg_dump" \
                kyokley/psql \
                "$@"
        }

        function pg_restore() {
            init-psql
            docker run \
                --rm -it \
                --net=host \
                -e "PGTZ=America/Chicago" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                -v $(pwd):/workspace \
                --entrypoint "pg_restore" \
                kyokley/psql \
                "$@"
        }

        # This function is specially designed to accept a db dump on stdin
        # and load it into a database
        function pg_load(){
            init-psql
            docker run \
                --rm -i \
                --net=host \
                -v "$HOME/.pgpass:/root/.pgpass" \
                kyokley/psql \
                "$@"
        }


        function createdb() {
            init-psql
            docker run \
                --rm -it \
                --net=host \
                -e "PGTZ=America/Chicago" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                --entrypoint "createdb" \
                kyokley/psql \
                "$@"
        }

        function dropdb() {
            init-psql
            docker run \
                --rm -it \
                --net=host \
                -e "PGTZ=America/Chicago" \
                -v "$HOME/.pgpass:/root/.pgpass" \
                --entrypoint "dropdb" \
                kyokley/psql \
                "$@"
        }
        if [ -f "$HOME/.zpriv" ]; then
            source "$HOME/.zpriv"
        fi
        ''
      ]);
      pmodules = [
        "environment"
        "autosuggestions"
        "terminal"
        "editor"
        "history"
        "history-substring-search"
        "directory"
        "spectrum"
        "utility"
        "completion"
        "ssh"
        "git"
        "syntax-highlighting"
        "prompt"
      ];
      utility.safeOps = false;
      prompt.showReturnVal = true;
      ssh.identities = [
        "id_ed25519"
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Kevin Yokley";
    userEmail = "kyokley2@gmail.com";
    delta.enable = true;
    extraConfig = {
      core = {
        editor = "nix run github:kyokley/nixvim --";
      };
      init = {
        defaultBranch = "main";
      };
    };
    aliases = {
      lol = ''log --graph --decorate --pretty=oneline --abbrev-commit --max-count=1000'';
      lola = ''log --graph --decorate --pretty=oneline --abbrev-commit --all --max-count=1000'';
      pullall = ''!git pull && git submodule update --init --recursive'';
      files = ''!git diff --name-only $(git merge-base HEAD "$GIT_BASE")'';
      stat = ''!git diff --stat $(git merge-base HEAD "$GIT_BASE")'';
      ls-files-root = ''!git ls-files'';
      ls-merges = ''!git log --merges --pretty=format:'%h %<(10,trunc)%aN %C(white)%<(15)%ar%Creset %C(red bold)%<(15)%D%Creset %s' -n 1000'';
      select = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | choose | xargs -r git switch'';
      fzf = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | fzf | xargs -r git switch'';
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
