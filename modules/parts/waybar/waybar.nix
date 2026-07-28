{
  flake.modules.homeManager.waybar = {pkgs, ...}: {
    services = {
      network-manager-applet.enable = true;
      blueman-applet.enable = true;
    };

    home.packages = [
      pkgs.wttrbar
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = ./classy.css;
      settings = {
        topBar = let
          mods = ["cpu" "memory" "disk" "battery" "pulseaudio"];
          modAttrDefaults =
            builtins.elemAt (builtins.concatLists (
              map (mod: {
                "group/${mod}" = {
                  orientation = "inherit";
                  modules = [
                    "${mod}#label"
                    "${mod}#data"
                  ];
                  drawer = {
                    transition-duration = 500;
                    children-class = "group-${mod}";
                    transition-left-to-right = true;
                    click-to-reveal = true;
                  };
                };
                "${mod}#label" = {
                  interval = 1;
                  tooltip = true;
                };
                "${mod}#data" = {
                  interval = 1;
                  format = "{icon} {usage}%";
                  tooltip = true;
                };
              })
              mods
            ))
            0;
        in
          modAttrDefaults
          // {
            layer = "top";
            position = "top";
            height = 60;

            modules-left = [
              "hyprland/window"
            ];

            "hyprland/window" = {
              max-length = 50;
            };

            modules-right =
              (map (mod: "group/${mod}") mods)
              ++ [
                "custom/weather"
                "tray"
                "clock"
              ];

            "cpu#label" = {
              format = "󰍛";
            };

            "cpu#data" = {
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            };

            "memory#label" = {
              format = "󰈀";
            };

            "memory#data" = {
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            };

            "disk#label" = {
              format = "󰋊";
            };

            "pulseaudio#label" = {
              format = "{icon}";
              format-muted = "󰝟";
              format-icons = {
                default = ["󰕿" "󰖀" "󰕾"];
              };
            };

            "pulseaudio#data" = {
              format = "{volume}%";
              format-muted = "󰝟 Muted";
              format-icons = {
                default = ["󰕿" "󰖀" "󰕾"];
              };
            };

            clock = {
              interval = 1;
              format = "󰅐 {:%H:%M:%S}";
              tooltip = true;
              tooltip-format = "{:%a %b %d}";
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

            "custom/weather" = {
              exec = "wttrbar --mph --nerd --fahrenheit --custom-indicator '{ICON} {FeelsLikeF}F'";
              return-type = "json";
              format = "{}";
              tooltip = true;
              interval = 900;
            };

            memory = {
              interval = 1;
              format = "󰈀 {icon} {percentage}%";
              tooltip = true;
              tooltip-format = "{used:0.1f}GiB / {total:0.1f}GiB";
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            };

            disk = {
              format = "󰋊 {percentage_used}%";
              tooltip = true;
              tooltip-format = "{used} / {total}";
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
              "class<kitty> title<.*(OpenCode|OC [|]).*>" = "";
              "class<kitty>" = "";
              "class<spotify>" = "";
              "class<brave-browser>" = "󰖟";
              "class<slack>" = "";
              "class<Mattermost.Desktop>" = "󰭹";
            };
          };
        };
      };
    };
  };
}
