{
  programs.git = {
    enable = true;
    userName = "Kevin Yokley";
    userEmail = "kyokley2@gmail.com";
    delta = {
      enable = true;
      options = {
        line-numbers = true;
      };
    };
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
    ignores = [
      ".python-version"
      ".zsh_config"
      "pyrightconfig.json"
      ".DS_Store"
      "__pycache__"
    ];
  };
}