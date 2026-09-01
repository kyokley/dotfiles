{
  flake.modules.homeManager = {
    common = {
      pkgs,
      lib,
      ...
    }: let
      clone-worktree = pkgs.writeShellApplication {
        name = "clone-worktree";
        runtimeInputs = [pkgs.git];
        text = ''
          # All credit to https://dev.to/metal3d/git-worktree-like-a-boss-2j1b
          # for this awesome setup
          dir=$(echo "$1" | grep -Po '(?<=/)\w+(?=($|\.git$))')

          # 1. Clone the repo into a hidden .bare folder
          ${pkgs.git}/bin/git clone --bare "$1" "$dir"/.bare

          # 2. Tell the root folder where the Git history is hidden
          cd "$dir"
          echo "gitdir: ./.bare" > .git

          # 3. Fix the fetch configuration to see all remote branches
          ${pkgs.git}/bin/git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
          ${pkgs.git}/bin/git fetch origin

          # 4. Create first worktree (the main branch)
          ${pkgs.git}/bin/git worktree add main || ${pkgs.git}/bin/git worktree add master
        '';
      };
    in {
      home.packages = [
        pkgs.fzf
        clone-worktree
      ];

      programs = {
        git = {
          enable = true;
          signing.format = null;
          settings = {
            init = {
              defaultBranch = "main";
            };
            user.name = "Kevin Yokley";
            user.email = lib.mkDefault "kyokley2@gmail.com";
            alias = {
              mt = "!nvim -c DiffviewOpen";
              lol = ''log --graph --decorate --pretty=oneline --abbrev-commit --max-count=1000'';
              lola = ''log --graph --decorate --pretty=oneline --abbrev-commit --all --max-count=1000'';
              pullall = ''!git pull && git submodule update --init --recursive'';
              files = ''!git diff --name-only $(git merge-base HEAD "$GIT_BASE")'';
              stat = ''!git diff --stat $(git merge-base HEAD "$GIT_BASE")'';
              ls-files-root = ''!git ls-files'';
              ls-merges = ''!git log --merges --pretty=format:'%h %<(10,trunc)%aN %C(white)%<(15)%ar%Creset %C(red bold)%<(15)%D%Creset %s' -n 1000'';

              fzf = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | ${pkgs.fzf}/bin/fzf | xargs -r git switch'';
              prune-merged = "!git branch --merged | grep -Ev '(^\*|^\+|main|master|develop)' | xargs --no-run-if-empty git branch -d";
            };
          };
          ignores = [
            ".python-version"
            ".zsh_config"
            "pyrightconfig.json"
            ".DS_Store"
            "__pycache__"
            ".nixos-test-history"
            "result"
            ".direnv"
          ];
        };

        delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            line-numbers = true;
          };
        };
      };
    };
  };
}
