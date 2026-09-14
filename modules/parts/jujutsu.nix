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
    ];
    programs = {
      jujutsu = {
        enable = true;
        settings = {
          user = {
            email = lib.mkDefault "${username}@${hostName}";
            name = lib.mkDefault fullName;
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
