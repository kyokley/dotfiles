{
  flake.modules = {
    nixos.hyprland = {
      inputs,
      pkgs,
      ...
    }: {
      systemd = {
        services."lock-on-sleep" = {
          description = "Lock screen before sleep";
          before = ["sleep.target"];
          wantedBy = ["sleep.target"];
          unitConfig.Type = "oneshot";
          serviceConfig.ExecStart = "loginctl lock-session";
        };

        # Ensure the greeter home directories exist before greetd/cagebreak
        # starts.  kitty (used by sysc-greet) needs .cache/kitty to write to,
        # but systemd-tmpfiles refuses to create dirs inside a non-root home
        # ("unsafe path transition").  A oneshot service solves this.
        services."greeter-home-setup" = {
          description = "Create greeter home directories for sysc-greet/kitty";
          before = ["greetd.service"];
          wantedBy = ["greetd.service"];
          unitConfig.Type = "oneshot";
          serviceConfig.ExecStart = pkgs.writeShellScript "greeter-home-setup" ''
            mkdir -p /var/lib/greeter/.cache/kitty
            mkdir -p /var/lib/greeter/.config
            mkdir -p /var/lib/greeter/.local/state
            chown -R greeter:greeter /var/lib/greeter
          '';
        };
      };

      programs = {
        hyprland = {
          enable = true;
          package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          # make sure to also set the portal package, so that they are in sync
          portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          withUWSM = true;
          xwayland.enable = true;
        };
      };

      services = {
        sysc-greet = {
          enable = true;
          compositor = "cagebreak";
          cagebreakPackage = pkgs.cagebreak;
        };
      };
    };

    homeManager.hyprland = {
      inputs,
      pkgs,
      lib,
      ...
    }: {
      imports = with inputs.self.modules.homeManager; [
        waybar
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        configType = "lua";
        systemd.enable = false;

        settings = {
          monitor = [
            {
              output = "eDP-1";
              mode = "2256x1504@60";
              position = "0x0";
              scale = "1";
            }
          ];

          mod = {
            # _var = "SUPER";
            _var = "ALT";
          };

          config = {
            general = {
              gaps_in = 20;
              gaps_out = 20;
              border_size = 5;
              layout = "master";
            };

            decoration = {
              rounding = 10;
            };
          };

          gesture = [
            {
              fingers = 3;
              direction = "horizontal";
              action = "workspace";
            }
          ];

          bind = let
            workspaceEntries = let
              mkWorkspace = ws_id: key: [
                {
                  _args = [
                    (lib.generators.mkLuaInline ''mod .. " + ${key}"'')
                    (lib.generators.mkLuaInline ''function() local ws = hl.get_active_workspace(); if ws and ws.id == ${ws_id} then hl.dispatch(hl.dsp.focus({ workspace = "previous" })) else hl.dispatch(hl.dsp.focus({ workspace = "${ws_id}" })) end end'')
                  ];
                }
                {
                  _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + ${key}"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "${ws_id}", follow = false })'')
                  ];
                }
              ];
              genIds = builtins.genList (x: let
                ws_id = toString (x + 1);
                key =
                  if x == 9
                  then "0"
                  else ws_id;
              in
                mkWorkspace ws_id key)
              10;
            in
              genIds ++ [(mkWorkspace "11" "MINUS")] ++ [(mkWorkspace "12" "EQUAL")];
            ws = builtins.concatLists workspaceEntries;
          in
            [
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + C"'')
                  # "SUPER + C"
                  (lib.generators.mkLuaInline "hl.dsp.window.close()")
                  {locked = true;}
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + RETURN"'')
                  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + P"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("noctalia msg panel-toggle launcher")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + Q"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("noctalia msg panel-toggle control-center")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + J"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("cyclenext")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + J"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.swap({ next = true })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + K"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("cycleprev")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + K"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.swap({ prev = true })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + RETURN"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("swapwithmaster ignoremaster")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + CONTROL + Q"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("rofi -show power-menu -modi power-menu:rofi-power-menu")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + H"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("mfact -0.1")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + L"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("mfact +0.1")'')
                ];
              }
              {
                # Move the window by dragging with ALT + left click (floats tiled windows)
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse:272"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.drag()'')
                  {
                    mouse = true;
                    drag = true;
                  }
                ];
              }
              {
                # Float the window under the cursor on ALT + left click
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse:272"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
                  {
                    mouse = true;
                    click = true;
                  }
                ];
              }
              {
                # Resize the window under the cursor with ALT + right click
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse:273"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.resize()'')
                  {mouse = true;}
                ];
              }
              {
                _args = [
                  "XF86AudioRaiseVolume"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pamixer -i 5")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86AudioLowerVolume"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pamixer -d 5")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86AudioMute"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pamixer -t")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86AudioPlay"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86AudioNext"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86AudioPrev"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86MonBrightnessUp"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -s set +5%")'')
                  {locked = true;}
                ];
              }
              {
                _args = [
                  "XF86MonBrightnessDown"
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -s set 5%-")'')
                  {locked = true;}
                ];
              }
            ]
            ++ ws;

          define_submap = {
            _args = [
              "resize"
              (lib.generators.mkLuaInline "function()\n  hl.bind(\"right\", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })\n  hl.bind(\"left\", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })\n  hl.bind(\"escape\", hl.dsp.submap(\"reset\"))\nend")
            ];
          };

          window_rule = [
            {
              match.class = "kitty";
              border_size = 3;
            }
            {
              match = {
                class = "zoom";
                float = true;
              };
              size = "638 510";
            }
            {
              match = {
                class = "zoom";
                title = "annotate_toolbar";
              };
              float = true;
              # expression vec2 splits on whitespace only; "200, 200" would
              # parse "200," as the x expression and fail
              size = "200 200";
            }
            {
              match.class = "zoom";
              workspace = "5 silent";
            }
            {
              match.class = "brave-browser";
              workspace = "6 silent";
            }
            {
              match.class = "Mattermost.Desktop";
              workspace = "10 silent";
            }
            {
              match.class = "Spotify";
              workspace = "7 silent";
            }
            {
              match.class = "slack";
              workspace = "8 silent";
            }
            {
              match.class = "brave-faolnafnngnfdaknnbpnkhgohbobgegn-Default"; # Outlook PWA
              workspace = "9 silent";
            }
          ];
        };
      };

      programs = {
        kitty.enable = true;
        hyprlock = {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
              ignore_empty_input = true;
            };

            animations = {
              enabled = true;
              fade_in = {
                duration = 300;
                bezier = "easeOutQuint";
              };
              fade_out = {
                duration = 300;
                bezier = "easeOutQuint";
              };
            };

            background = [
              {
                path = "screenshot";
                blur_passes = 3;
                blur_size = 8;
              }
            ];

            input-field = [
              {
                size = "200, 50";
                position = "0, -80";
                monitor = "";
                dots_center = true;
                fade_on_empty = false;
                font_color = "rgb(202, 211, 245)";
                inner_color = "rgb(91, 96, 120)";
                outer_color = "rgb(24, 25, 38)";
                outline_thickness = 5;
                placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
                shadow_passes = 2;
              }
            ];
          };
        };
      };

      home = {
        packages = [
          pkgs.libnotify
          pkgs.pamixer
          pkgs.brightnessctl
          pkgs.playerctl
        ];

        pointerCursor = {
          enable = true;
          gtk.enable = true;
          x11.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 16;
        };
      };

      gtk = {
        enable = true;
        gtk4.theme = null;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        theme = {
          name = "Catppuccin-Mocha-Standard-Blue-dark";
          package = pkgs.catppuccin-gtk;
        };
      };

      services = {
        hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";
            };
            listener = [
              {
                timeout = 150;
                on-timeout = "brightnessctl -s set 10";
                on-resume = "brightnessctl -r";
              }
              {
                timeout = 300;
                on-timeout = "loginctl lock-session";
              }
              {
                timeout = 330;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
              {
                timeout = 600;
                on-timeout = "systemctl suspend";
              }
            ];
          };
        };
        hyprpolkitagent.enable = true;
        wpaperd = {
          enable = true;
          settings = {
            eDP-1 = {
              path = "/home/yokley/Pictures/wallpapers";
              duration = "5m";
            };
          };
        };
      };

      systemd.user.services."spotify-song-notify" = {
        Unit = {
          Description = "Notify on Spotify song changes";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "spotify-notify" ''
            ${pkgs.playerctl}/bin/playerctl --player=spotify --follow metadata --format '{{title}} - {{artist}}' 2>/dev/null | \
              while read -r line; do
                if [ -n "$line" ]; then
                  ${pkgs.libnotify}/bin/notify-send -i spotify "Now Playing" "$line"
                fi
              done
          ''}";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
