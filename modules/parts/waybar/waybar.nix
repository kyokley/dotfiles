{
  flake.modules.homeManager.waybar = {
    pkgs,
    lib,
    ...
  }: {
    services = {
      network-manager-applet.enable = true;
      blueman-applet.enable = true;
    };

    home.packages = [
      pkgs.wttrbar
      pkgs.jq
    ];

    programs.waybar = {
      enable = false;
      systemd.enable = true;
      style = ./style.css;
      settings = let
        mods = [
          "custom/cpu_max"
          "memory"
          "disk"
          "battery"
          "pulseaudio"
          "custom/weather"
        ];
        modAttrDefaults = builtins.foldl' (a: b: a // b) {} (
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
              interval = lib.mkDefault 1;
              tooltip = lib.mkDefault true;
            };
            "${mod}#data" = {
              interval = lib.mkDefault 1;
              format = lib.mkDefault "{icon} {usage}%";
              tooltip = lib.mkDefault true;
            };
          })
          mods
        );
      in [
        (lib.attrsets.recursiveUpdate modAttrDefaults
          {
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
              ["network"]
              ++ (map (mod: "group/${mod}") mods)
              ++ [
                "tray"
                "clock"
              ];

            network = {
              format = "󰓅";
              format-alt = "{bandwidthDownBytes} 󰓅 {bandwidthUpBytes}";
              tooltip = true;
              tooltip-format = "{essid}  {signalStrength}%  {ipaddr}/{cidr}";
              interval = 2;
            };

            "custom/cpu_max#label" = {
              return-type = "json";
              format = "󰍛";
              exec = ''
                awk '/^cpu[0-9]/ {t[$1]=$2+$3+$4+$5; i[$1]=$5}
                  END {
                    system("sleep 0.5")
                    while ((getline < "/proc/stat") > 0)
                      if ($1 ~ /^cpu[0-9]/) {
                        td = $2+$3+$4+$5 - t[$1]
                        id = $5 - i[$1]
                        if (td > 0) {
                          u = int((td - id) / td * 100 + 0.5)
                          if (u > m) m = u
                        }
                      }
                    close("/proc/stat")
                    m = m != "" ? m : 0
                    if (m >= 90) printf "{\"text\":\"%d%%\",\"class\":\"critical\"}\n", m
                    else if (m >= 60) printf "{\"text\":\"%d%%\",\"class\":\"warning\"}\n", m
                    else printf "{\"text\":\"%d%%\"}\n", m
                  }' /proc/stat
              '';
              interval = 2;
              tooltip = false;
            };

            "custom/cpu_max#data" = {
              return-type = "json";
              format = "{}";
              exec = ''
                awk '/^cpu[0-9]/ {t[$1]=$2+$3+$4+$5; i[$1]=$5}
                  END {
                    system("sleep 0.5")
                    while ((getline < "/proc/stat") > 0)
                      if ($1 ~ /^cpu[0-9]/) {
                        td = $2+$3+$4+$5 - t[$1]
                        id = $5 - i[$1]
                        if (td > 0) {
                          u = int((td - id) / td * 100 + 0.5)
                          if (u > m) m = u
                        }
                      }
                    close("/proc/stat")
                    m = m != "" ? m : 0
                    if (m >= 90) printf "{\"text\":\"%d%%\",\"class\":\"critical\"}\n", m
                    else if (m >= 60) printf "{\"text\":\"%d%%\",\"class\":\"warning\"}\n", m
                    else printf "{\"text\":\"%d%%\"}\n", m
                  }' /proc/stat
              '';
              interval = 2;
              tooltip = false;
            };

            "memory#label" = {
              format = "󰈀";
            };

            "memory#data" = {
              format = "{percentage}%";
              tooltip = true;
              tooltip-format = "{used:0.1f}GiB / {total:0.1f}GiB";
              states = {
                warning = 70;
                critical = 90;
              };
            };

            "disk#label" = {
              format = "󰋊";
              interval = 60;
            };

            "disk#data" = {
              format = "{percentage_used}%";
              tooltip = true;
              tooltip-format = "{used} / {total}";
              interval = 60;
              states = {
                warning = 70;
                critical = 90;
              };
            };

            "pulseaudio#label" = {
              format = "{icon}";
              format-muted = "󰝟";
              format-icons = {
                default = [
                  "󰕿"
                  "󰖀"
                  "󰖀"
                  "󰕾"
                  "󰕾"
                  "󰕾"
                  "󰕾"
                  "󰕾"
                  "󰕾"
                  "󰕾"
                ];
              };
            };

            "pulseaudio#data" = {
              format = "{volume}%";
              format-muted = "󰝟 Muted";
            };

            "battery#label" = {
              format = "{icon}";
              states = {
                warning = 35;
                critical = 15;
              };
              format-charging = "󰂄";
              format-plugged = "󰂄";
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
              interval = 900;
            };

            "battery#data" = {
              format = lib.mkForce "{capacity}%";
              states = {
                warning = 35;
                critical = 15;
              };
              format-charging = "{capacity}%";
              format-plugged = "{capacity}%";
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
              interval = 900;
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

            "custom/weather#label" = {
              exec = ''
                ${pkgs.wttrbar}/bin/wttrbar --mph --nerd --fahrenheit --custom-indicator '{ICON} {temp_F}F' \
                  | ${pkgs.jq}/bin/jq -c '(.text | capture("(?<t>[0-9]+)F").t | tonumber) as $t
                    | .text |= sub(" [0-9]+F$"; "")
                    | if $t >= 95 then .class = [.class, "hot-critical"]
                      elif $t >= 85 then .class = [.class, "hot-warning"]
                      elif $t <= 20 then .class = [.class, "cold-critical"]
                      elif $t <= 32 then .class = [.class, "cold-warning"]
                      else . end'
              '';
              return-type = "json";
              format = "{}";
              tooltip = true;
              interval = 900;
            };

            "custom/weather#data" = {
              exec = ''
                ${pkgs.wttrbar}/bin/wttrbar --mph --nerd --fahrenheit --custom-indicator '{temp_F}F {weatherDesc}' \
                  | ${pkgs.jq}/bin/jq -c '(.text | capture("(?<t>[0-9]+)F").t | tonumber) as $t
                    | if $t >= 95 then .class = [.class, "hot-critical"]
                      elif $t >= 85 then .class = [.class, "hot-warning"]
                      elif $t <= 20 then .class = [.class, "cold-critical"]
                      elif $t <= 32 then .class = [.class, "cold-warning"]
                      else . end'
              '';
              return-type = "json";
              format = "{}";
              tooltip = true;
              interval = 900;
            };
          })

        {
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
        }
      ];
    };
  };
}
