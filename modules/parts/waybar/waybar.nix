{
  flake.modules.homeManager.waybar = {
    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = ./classy.css;
      settings = {
        topBar = {
          layer = "top";
          position = "top";
          height = 60;

          modules-left = [
            "hyprland/window"
          ];
          modules-right = [
            "cpu"
            "memory"
            "disk"
            "battery"
            "pulseaudio"
            "tray"
            "clock"
          ];

          "hyprland/window" = {
            max-length = 50;
          };

          clock = {
            format = "{:%H:%M %d/%m/%Y}";
          };

          tray = {
            icon-size = 32;
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

          cpu = {
            interval = 1;
            format = "󰍛 {icon} {usage:>2}%";
            tooltip = true;
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          };

          memory = {
            interval = 1;
            format = "󰈀 {icon} {percentage:>2}%";
            tooltip = true;
            tooltip-format = "{used:0.1f}GiB / {total:0.1f}GiB";
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          };

          disk = {
            format = "󰋊 {percentage_used:>2}%";
            tooltip = true;
            tooltip-format = "{used} / {total}";
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity:>2}%";
            format-charging = "󰂄 {capacity:>2}%";
            format-plugged = "󰂄 {capacity:>2}%";
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
          height = 60;

          modules-left = [
            "hyprland/workspaces"
          ];
          "hyprland/workspaces" = {
            format = "{name} {windows}";
            sort-by = "id";
            all-outputs = true;
            format-icons = {
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
              "0" = "";
              # "active" = "";
              # "default" = "";
            };

            "format-window-separator" = " ";
            "window-rewrite-default" = "";
            "window-rewrite" = {
              "class<firefox>" = "";
              "class<title<.*github.*>" = "";
              "title<.*youtube.*>" = "";
              "class<kitty>" = "";
              "class<spotify>" = "";
              "class<brave-browser>" = "󰖟";
              "title<.*(OpenCode|OC).*>" = "";
              "class<slack>" = "";
              "class<Mattermost.Desktop>" = "󰭹";
            };
          };
        };
      };
    };
  };
}
