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
