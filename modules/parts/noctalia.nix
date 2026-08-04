{
  flake.modules.homeManager.noctalia = {
    inputs,
    username,
    ...
  }: {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        theme = {
          mode = "dark";
          source = "community";
          community_palette = "Cyberpunk";
        };

        wallpaper = {
          enabled = true;
          directory = "/home/${username}/Pictures/wallpapers";
          transition = ["fade"];
          transition_duration = 1500;
          fill_mode = "crop";
        };

        # Top floating bar with capsule widgets.
        bar = let
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
        in {
          main =
            bar_base
            // {
              position = "top";
              layer = "top";
              # Horizontal bar: start = left, center = middle, end = right.
              start = [
                "control-center"
              ];
              center = ["sysmon" "clock" "media"];
              end = [
                "tray"
                "volume"
                "input_volume"
                "brightness"
                "battery"
                "notifications"
                "launcher"
              ];
            };

          bottom =
            bar_base
            // {
              position = "bottom";
              # layer = "top";
              start = ["workspaces"];
              # noctalia merges per-lane: absent center/end keep the default
              # widget lists (clock; media/tray/notifications/.../session).
              center = [];
              end = [];
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
        };

        widget = {
          workspaces = {
            active_pill_size = 1.5;
            empty_color = "surface_variant";
            occupied_color = "secondary"; # Cyberpunk red
            hide_when_empty = true;
            label_source = "id";
            show_labels = true;
          };
          clock = {
            format = "{:%H:%M:%S}";
            # \\n survives TOML escaping; noctalia renders it as a line break.
            vertical_format = "{:%H\\n%M\\n%S}";
            tooltip_format = "{:%a, %b %d}";
            capsule_opacity = 0.4;
            capsule_padding = 4;
          };
          launcher.glyph = "rocket";
          volume.show_label = false;
          input_volume.show_label = false;
          brightness.show_label = false;
          battery.show_label = false;
          sysmon.show_value = false;
          media = {
            hide_when_no_media = true;
            album_art_only = false;
          };
          tray.drawer = true;
        };

        shell = {
          font_family = "Hack Nerd Font Mono"; # installed via nerd-fonts.hack
          telemetry_enabled = false;
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
  };
}
