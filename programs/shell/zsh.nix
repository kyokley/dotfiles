{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellGlobalAliases = {
      vim = "nix run github:kyokley/nixvim --";
    };
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
}
