{
  flake.modules.homeManager.noctalia = {
    inputs,
    pkgs,
    config,
    username,
    ...
  }: let
    krillPlugin = ./krill;
  in {
    imports = [inputs.noctalia.homeModules.default];

    # Krill is a hand-placed local plugin: noctalia auto-discovers
    # ~/.local/share/noctalia/plugins/<plugin>/ as a built-in local source.
    home.file = {
      ".local/share/noctalia/plugins/krill/plugin.toml" = {
        source = krillPlugin + "/plugin.toml";
      };
      ".local/share/noctalia/plugins/krill/widget.luau" = {
        source = krillPlugin + "/widget.luau";
      };
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        calendar = {
          enabled = true;
          refresh_minutes = 15;
          account = {
            personal_google = {
              type = "google";
              name = "Personal";
            };
          };
        };

        battery = {
          warning_threshold = 25;
        };

        theme = {
          mode = "auto";
          source = "wallpaper";
          wallpaper_scheme = "vibrant";
        };

        wallpaper = {
          enabled = true;
          directory = "/home/${username}/Pictures/wallpapers";
          transition = ["fade" "wipe" "disc" "stripes" "zoom" "honeycomb"];
          transition_duration = 2000;
          fill_mode = "crop";
          automation = {
            enabled = true;
            interval_seconds = 1800;
            order = "random";
            recursive = true;
          };
        };

        # Location is required for weather to resolve a forecast.
        # auto_locate uses IP geolocation; switch to `address` (e.g. "Austin, TX")
        # if the IP lookup is inaccurate.
        location = {
          auto_locate = true;
        };

        # Weather service (Open-Meteo, no API key). Adds the Weather control-center tab.
        weather = {
          enabled = true;
          refresh_minutes = 30;
          unit = "imperial";
          effects = true;
        };

        # Top floating bar with capsule widgets.
        bar = let
          mkCapsuleGroup = attrs:
            {
              enabled = true;
              accordion = true;
              # Groups carry their own capsule style (they don't inherit the
              # bar-level capsule_* keys) — mirror the bar's settings here.
              fill = "primary";
              opacity = 0.25;
              radius = 8;
              padding = 4;
              border = "primary";
            }
            // attrs;
          bar_base = {
            thickness = 52;
            background_opacity = 0.9;
            scale = 1.8;
            border_width = 0;
            radius = 14;
            margin_ends = 8;
            margin_edge = 8;
            margin_opposite_edge = 0;
            padding = 6;
            widget_spacing = 4;
            shadow = true;
            reserve_space = true;
            font_weight = 600;
            capsule = true;
            capsule_fill = "primary"; # tracks the Cyberpunk gold
            capsule_opacity = 0.25;
            capsule_padding = 4;
            capsule_radius = 8;
            capsule_border = "primary";
          };
          grouped_widgets = [
            "cpu"
            "ram"
            "disk"
            "battery"
            "volume"
          ];
          single_widgets = [
            "tray"
            "notifications"
            "weather"
            "clock"
          ];
        in {
          top =
            bar_base
            // {
              position = "top";
              layer = "top";
              # Horizontal bar: start = left, center = middle, end = right.
              start = [
                "active_window"
              ];
              center = ["media"];
              end =
                (map (x: "group:${x}") grouped_widgets) # Above are "grouped" widgets. Below are singular.
                ++ single_widgets;
              # Capsule groups are declared on the bar as an array of tables,
              # referenced from lanes via the "group:<id>" token.
              capsule_group = map (x:
                mkCapsuleGroup
                {
                  id = x;
                  members = [
                    "${x}-icon"
                    "${x}-info"
                  ];
                })
              grouped_widgets;
            };

          bottom =
            bar_base
            // {
              position = "bottom";
              # layer = "top";
              start = ["workspaces"];
              # noctalia merges per-lane: absent center/end keep the default
              # widget lists (clock; media/tray/notifications/.../session).
              center = ["audio_visualizer"];
              end = ["krill"];
              capsule_group = [
              ];
            };
        };

        notification = {
          # Toasts anchor to the screen edge at absolute offsets, while the
          # full-width floating top bar owns y ∈ [8, 60] on layer "top".
          # Default offset_y = 8 puts popups behind the bar; drop them below
          # it so notifications actually display.
          position = "top_right";
          offset_x = 20;
          offset_y = 64;
          filter = {
            spotify = {
              enabled = true;
              show_toast = false;
              save_history = false;
              play_sound = false;
              match = "notify-send";
              match_content = "Now Playing";
            };
            brave-browser = {
              enabled = true;
              show_toast = true;
              save_history = true;
              play_sound = true;
              match = "Brave Web Browser";
              allow_permanent = false;
            };
            slack = {
              enabled = true;
              show_toast = true;
              save_history = false;
              play_sound = true;
              match = "Slack";
              allow_permanent = false;
            };
          };
        };

        widget = {
          active_window = {
            max_length = 400;
            title_scroll = "on_hover";
          };
          audio_visualizer = {
            centered = false;
            interactive = false;
            width = 200;
            bands = 32;
          };
          cpu-icon = {
            type = "sysmon";
            stat = "cpu_usage";
            glyph = "cpu-usage";
            visualization = "none";
            show_value = false;
          };
          cpu-info = {
            type = "sysmon";
            stat = "cpu_usage";
            show_glyph = false;
            visualization = "graph";
            show_value = true;
          };
          ram-icon = {
            type = "sysmon";
            stat = "ram_pct";
            glyph = "cpu";
            visualization = "none";
            show_value = false;
          };
          ram-info = {
            type = "sysmon";
            stat = "ram_pct";
            show_glyph = false;
            visualization = "graph";
            show_value = true;
          };
          disk-icon = {
            type = "sysmon";
            stat = "disk_used_pct";
            glyph = "database-smile";
            visualization = "none";
            show_value = false;
          };
          disk-info = {
            type = "sysmon";
            stat = "disk_used_pct";
            show_glyph = false;
            visualization = "graph";
            show_value = true;
          };
          battery-icon = {
            type = "battery";
            display_mode = "glyph";
            show_label = false;
          };
          battery-info = {
            type = "battery";
            display_mode = "none";
            show_label = true;
          };
          volume-icon = {
            type = "volume";
            show_label = false;
          };
          volume-info = {
            type = "volume";
            glyph = "none";
            custom_image = "none";
            show_label = true;
          };
          weather = {
            show_condition = false;
            show_temperature = true;
          };
          workspaces = {
            active_pill_size = 2.0;
            empty_color = "surface_variant";
            occupied_color = "secondary"; # Cyberpunk red
            hide_when_empty = true;
            label_source = "id";
            show_labels = true;
          };
          clock = {
            format = "{:%b %d %H:%M:%S}";
            # \\n survives TOML escaping; noctalia renders it as a line break.
            vertical_format = "{:%H\\n%M\\n%S}";
            tooltip_format = "{:%a, %b %d}";
            capsule_opacity = 0.4;
            capsule_padding = 4;
          };
          launcher.glyph = "rocket";
          brightness.show_label = false;
          sysmon.show_value = false;
          media = {
            hide_when_no_media = true;
            album_art_only = false;
            # Explicit: left-click opens the control-center media panel.
            # (This matches noctalia's built-in default for media.)
            actions.left = "panel-toggle control-center media";
            title_scroll = "always";
          };
          tray.drawer = false;
          # Runtime-updatable krill headline (plugin entry "yokley/krill:krill").
          # Pushed via: noctalia msg plugin yokley/krill:krill all set "<text>|<url>"
          krill = {
            type = "yokley/krill:krill";
            # Per-widget scale MULTIPLIES the bar's 1.8 (clamped 0.2–2.5), so
            # 0.8 × 1.8 = 1.44 renders the headline ~20% smaller.
            scale = 0.8;
          };
        };

        shell = {
          font_family = "Hack Nerd Font Mono"; # installed via nerd-fonts.hack
          telemetry_enabled = false;
          # Panels opened without a source bar (IPC panel-toggle, shortcuts, dock)
          # attach to the first enabled bar alphabetically (`bottom` in TOML order) —
          # pin them to the top bar instead.
          panel_anchor_bar = "top";
          panel = {
            transparency_mode = "soft";
            launcher_placement = "attached";
            control_center_placement = "attached";
          };
          screen_corners = {
            enabled = true;
            size = 18;
          };
        };

        # Noctalia has no per-surface font size; ui_scale is the only lever that
        # affects the control-center (it scales launcher/clipboard too, not the bar).
        accessibility.ui_scale = 1.5;
      };
    };

    # Push a random krill headline to the bar widget on a timer.
    systemd.user = {
      services.krill-bar = {
        Unit = {
          Description = "Push a random krill headline to the noctalia bar";
          After = ["graphical-session.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "krill-bar" ''
            set -uo pipefail
            item=$(${pkgs.docker}/bin/docker run --rm -t --cpus=.25 --net=host \
              --env KRILL_PROXY=''${KRILL_PROXY:-} \
              kyokley/krill -S /app/sources.txt --snapshot 2>/dev/null \
              | ${pkgs.jq}/bin/jq -c 'select(.title != null)' \
              | ${pkgs.coreutils}/bin/shuf -n1) || true
            if [ -n "''${item:-}" ]; then
              title=$(${pkgs.jq}/bin/jq -r '.title' <<<"$item")
              link=$(${pkgs.jq}/bin/jq -r '.link // empty' <<<"$item")
              # "|" separates the headline from its url inside the single IPC
              # payload (the runtime passes onIpc exactly one payload string);
              # the widget splits at the last "|" so urls never contain one.
              ${config.programs.noctalia.package}/bin/noctalia msg plugin yokley/krill:krill all set "$title|$link" || true
            fi
          '');
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      timers.krill-bar = {
        Unit.Description = "Refresh the krill bar widget";
        Timer = {
          OnCalendar = "*-*-* *:*:00";
          Persistent = true;
          Unit = "krill-bar.service";
        };
        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
