{
  flake.modules.homeManager.common = {
    lib,
    fullName,
    pkgs,
    username,
    hostName,
    ...
  }: {
    home.packages = with pkgs; [
      lazyjj
      jjui
      difftastic
      alejandra
      ruff
    ];
    programs = {
      jujutsu = {
        enable = true;
        settings = {
          user = {
            email = lib.mkDefault "${username}@${hostName}";
            name = lib.mkDefault fullName;
          };
          ui = {
            default-command = "log";
            diff-editor = ":builtin";
            # pager = "delta";
            # diff-formatter = ":git";
            diff-formatter = ["difft" "--color=always" "$left" "$right"];
          };
          fix.tools = {
            "1-ruff-lint" = {
              command = "${pkgs.ruff}/bin/ruff check --fix --quiet --stdin-filename=$path -";
              patterns = ["glob:'**/*.py'"];
            };
            "2-ruff-lint" = {
              command = "${pkgs.ruff}/bin/ruff format --stdin-filename=$path -";
              patterns = ["glob:'**/*.py'"];
            };
            alejandra = {
              command = "${pkgs.alejandra}/bin/alejandra -";
              patterns = ["glob:'**/*.nix'"];
            };
          };
        };
      };
      jjui = {
        enable = true;
        settings = {
          bindings = [
            {
              key = "ctrl+j";
              action = "ui.preview_scroll_down";
              scope = "ui.preview";
            }
            {
              key = "ctrl+k";
              action = "ui.preview_scroll_up";
              scope = "ui.preview";
            }
          ];
        };
      };
    };
  };
}
