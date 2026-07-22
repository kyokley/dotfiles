{
  flake.modules.homeManager.waybar = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        topBar = {
          layer = "top";
          position = "top";
          height = 30;

          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "tray"
            "clock"
          ];

          "hyprland/window" = {
            max-length = 50;
          };

          clock = {
            format = "{:%H:%M}";
          };

          tray = {
            icon-size = 16;
            spacing = 10;
          };
        };

        bottomBar = {
          layer = "top";
          position = "bottom";
          height = 30;

          modules-left = [
            "hyprland/workspaces"
          ];
          "hyprland/workspaces" = {
            format = "{name} {icon}";
            sort-by = "id";
            all-outputs = true;
            "format-icons" = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
              # "active" = "";
              # "default" = "";
            };
          };

          "hyprland/window" = {
            max-length = 50;
          };

          clock = {
            format = "{:%H:%M}";
          };
        };
      };
    };
  };
}
