{
  flake.modules.homeManager.common = {pkgs, ...}: {
    programs.zsh = {
      enable = true;
      # enableCompletion = true;
      # syntaxHighlighting.enable = true;
      # zprof.enable = true;
      prezto = {
        enable = true;
        package = pkgs.zsh-prezto.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              # Include P10k's saved command in the OSC 133 marker it emits
              # after Kitty's marker, preserving notify_on_cmd_finish's %c.
              substituteInPlace modules/prompt/external/powerlevel10k/internal/p10k.zsh \
                --replace-fail "  [[ -t 1 ]] && builtin print -n '\e]133;C;\a'" \
                  "  [[ -t 1 ]] && builtin print -n -f '\e]133;C;cmdline=%q\a' -- \"\$_p9k__preexec_cmd\""
            '';
        });
        caseSensitive = false;
        syntaxHighlighting.highlighters = [
          "main"
          "brackets"
          "pattern"
          "line"
          "cursor"
          "root"
        ];
        prompt = {
          theme = "powerlevel10k";
          showReturnVal = true;
        };
        pmodules = [
          "environment"
          "terminal"
          "editor"
          "history"
          "spectrum"
          "utility"
          "completion" # completion module can lead to slow terminal start times
          "syntax-highlighting"
          "history-substring-search"
          "ssh"
          "tmux"
          "git"
          "autosuggestions"
          "prompt"
        ];
        utility.safeOps = false;
        ssh.identities = [
          "id_ed25519"
        ];
        tmux.autoStartRemote = true;
        extraConfig = builtins.concatStringsSep "\n" [
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

            function krill() {
                docker run \
                    --rm -t \
                    --net=host \
                    --env KRILL_PROXY=$HTTP_PROXY \
                    kyokley/krill \
                    "$@"
            }

            function qw() {
                docker run \
                    --rm -t \
                    kyokley/quick-word \
                    "$@"
            }

            if [ -f "$HOME/.zpriv" ]; then
                source "$HOME/.zpriv"
            fi

            if [ -f "$HOME/.config/age/plugin-identity.txt" ]; then
              export AGE_IDENTITY=$(cat $HOME/.config/age/plugin-identity.txt)
            fi
          ''
        ];
      };
    };
  };
}
