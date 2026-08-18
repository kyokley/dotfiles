{
  flake.modules = {
    homeManager.noctalia = {
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

      # evtest feeds keyboard events to the bongo cat widget.
      home.packages = [pkgs.evtest];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings = {
          # Plugins enabled declaratively. These ids must live here:
          #   - noctalia/bongocat — official plugin (the `official` git source
          #     ships by default; enabling the id fetches + activates it)
          #   - dotnetrob/cat — community plugin (the `community` git source
          #     ships by default, same as `official`)
          #   - yokley/krill — local plugin placed under
          #     ~/.local/share/noctalia/plugins/krill (built-in local source)
          #
          # NOTE: the app keeps a `[plugins]` override in
          # ~/.local/state/noctalia/settings.toml (written when you enable or
          # disable a plugin from the GUI/IPC) that WINS over this list until
          # removed. If a plugin added here doesn't load, check that file.
          plugins = {
            enabled = [
              "noctalia/bongocat"
              "dotnetrob/cat"
              "yokley/krill"
            ];
          };

          idle = {
            pre_action_fade_seconds = 30.0;
            behavior_order = [
              "lock"
              "screen-off"
              "suspend"
            ];
            behavior = {
              lock = {
                enabled = true;
                timeout = 600;
                action = "lock";
              };
              screen-off = {
                enabled = true;
                timeout = 600;
                action = "screen_off";
                locked_timeout = 30;
              };
              suspend = {
                enabled = true;
                timeout = 900;
                action = "suspend";
                lock_before_suspend = false;
              };
            };
          };

          # Native ext-session-lock lockscreen. Also arms the logind sleep-delay
          # inhibit so noctalia locks the screen before ANY suspend, including
          # lid-triggered HandleLidSwitch=suspend from logind.
          lockscreen = {
            enabled = true;
          };

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
                  "bongocat"
                  "active_window"
                ];
                center = ["media"];
                end =
                  (map (x: "group:${x}") grouped_widgets)
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
              # Named "aaa-…" so it sorts before the generic `brave-browser`
              # filter (the generated TOML and noctalia's parser both order
              # filter tables by name, and resolveNotificationFilter returns the
              # FIRST match). The generic filter must not swallow Proton VPN
              # notifications before this specific one can see them.
              aaa-brave-proton = {
                enabled = true;
                show_toast = true;
                save_history = false;
                play_sound = true;
                match = "brave";
                match_content = "Proton VPN";
                allow_permanent = false;
              };
              brave-browser = {
                enabled = true;
                show_toast = true;
                save_history = true;
                play_sound = true;
                match = "brave";
                allow_permanent = false;
              };
              network-manager = {
                enabled = true;
                show_toast = true;
                save_history = false;
                play_sound = true;
                match = "networkmanager";
                allow_permanent = false;
              };
              slack = {
                enabled = true;
                show_toast = true;
                save_history = false;
                play_sound = true;
                match = "slack";
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
              type = "dotnetrob/cat:cat";
              enabled = true;
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
              focused_output_only = true;
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

            # Bongo cat (official plugin noctalia/bongocat). Reads keyboard
            # events via evtest (installed via home.packages below; the user is
            # in the `input` group so the session can open /dev/input/*). The
            # stable by-path glob matches the internal i8042 keyboard and any
            # USB/Bluetooth keyboard that exposes a by-path symlink.
            #
            # enabled = false hides the cat from the bar (v5 has no IPC for
            # per-widget visibility); flip it to true to bring it back.
            bongocat = {
              type = "noctalia/bongocat:cat";
              input_devices = [
                "/dev/input/by-path/*-event-kbd"
              ];
              enabled = true;
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

          system = {
            monitor = {
              enabled = true;
              cpu_usage_activity_threshold = 50;
              cpu_usage_critical_threshold = 90;
              ram_pct_activity_threshold = 60;
              ram_pct_critical_threshold = 90;
              disk_used_pct_activity_threshold = 80;
              disk_used_pct_critical_threshold = 90;
            };
          };

          # Noctalia has no per-surface font size; ui_scale is the only lever that
          # affects the control-center (it scales launcher/clipboard too, not the bar).
          accessibility.ui_scale = 1.5;
        };
      };

      wayland.windowManager.hyprland = {
        settings.layer_rule = [
          {
            name = "noctalia";
            match = {
              namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
            };
            no_anim = true;
            ignore_alpha = 0.5;
            blur = true;
            blur_popups = true;
          }
        ];
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
                # Unit separator (0x1F) joins title and url in the single IPC
                # payload — it never appears in headlines or URLs, unlike "|".
                ${config.programs.noctalia.package}/bin/noctalia msg plugin yokley/krill:krill all set "$title"$'\x1f'"$link" || true
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

        # Noctalia has no config key to auto-inhibit idle while media plays;
        # caffeine (its idle inhibitor) is manual-only (IPC or widget). Watch
        # MPRIS playback (playerctl follows the default player, i.e. Spotify
        # when it's the one playing) and mirror "Playing"/not-Playing to the
        # caffeine IPC so the machine never sleeps mid-song. Caffeine blocks
        # ALL idle behaviors (screen-off, lock, suspend), which is the point:
        # otherwise the screen would still go dark and lock under the music.
        services.noctalia-caffeine = {
          Unit = {
            Description = "Enable noctalia caffeine while media is playing";
            After = ["graphical-session.target"];
          };
          Service = {
            Type = "simple";
            ExecStart = toString (pkgs.writeShellScript "noctalia-caffeine" ''
              set -uo pipefail

              while true; do
                # playerctld pins a stable "default player" across app
                # switches; without it --follow only tracks the first player
                # seen. `daemon` activates it via D-Bus and exits.
                ${pkgs.playerctl}/bin/playerctld daemon || true

                # Each line is the default player's status: "Playing",
                # "Paused" or "Stopped". playerctl exits when no players
                # exist, so re-attach after a short delay.
                ${pkgs.playerctl}/bin/playerctl --follow status 2>/dev/null \
                  | while read -r status; do
                      if [ "$status" = "Playing" ]; then
                        ${config.programs.noctalia.package}/bin/noctalia msg caffeine-enable || true
                      else
                        ${config.programs.noctalia.package}/bin/noctalia msg caffeine-disable || true
                      fi
                    done

                sleep 5
              done
            '');
            Restart = "on-failure";
          };
          Install.WantedBy = ["graphical-session.target"];
        };
      };
    };
    nixos.noctalia = {
      inputs,
      username,
      ...
    }: {
      imports = [
        inputs.noctalia.nixosModules.default
      ];
      nix = {
        settings = {
          extra-substituters = ["https://noctalia.cachix.org"];
          extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
        };
      };

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      # auto-cpufreq (laptop module) owns the power-profile slot on this host;
      # without this, noctalia's recommendedServices would also enable
      # power-profiles-daemon, which NixOS forbids.
      services.power-profiles-daemon.enable = false;

      # Bongo cat reads /dev/input/event* (root:input, mode 660) via evtest —
      # membership in `input` lets the session open the devices.
      users.users.${username}.extraGroups = ["input"];
    };
  };
}
