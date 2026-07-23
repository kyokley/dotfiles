{
  flake.modules.homeManager.waybar = {
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = ./style.css;
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
            "pulseaudio"
            "battery"
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

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰝟 Muted";
            format-icons = {
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = "pavucontrol";
            tooltip = true;
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            tooltip = true;
            tooltip-format = "{timeTo}";
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
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
              # "active" = "";
              # "default" = "";
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
