{lib, ...}: {
  programs.git = {
    enable = true;
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
        select = lib.mkDefault ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | rofi -dmenu -p "Branch:" | xargs -r git switch'';

        fzf = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | fzf | xargs -r git switch'';
      };
    };
    ignores = [
      ".python-version"
      ".zsh_config"
      "pyrightconfig.json"
      ".DS_Store"
      "__pycache__"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
    };
  };
}
