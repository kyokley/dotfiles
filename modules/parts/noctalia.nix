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
        bar.main = {
          position = "top";
          layer = "top";
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
          # Horizontal bar: start = left, center = middle, end = right.
          start = ["launcher" "workspaces"];
          center = ["sysmon" "date" "media"];
          end = [
            "tray"
            "volume"
            "input_volume"
            "brightness"
            "battery"
            "notifications"
            "control-center"
          ];
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
            format = "{:%H:%M}";
            # \\n survives TOML escaping; noctalia renders it as a line break.
            vertical_format = "{:%H\\n%M}";
            tooltip_format = "{:%H:%M  %a, %b %d}";
            capsule_opacity = 0.4;
            capsule_padding = 4;
          };
          launcher.glyph = "rocket";
          volume.show_label = false;
          input_volume.show_label = false;
          brightness.show_label = false;
          battery.show_label = false;
          sysmon.show_value = false;
          media.album_art_only = false;
          tray.drawer = true;
        };

        # Remove this section if you don't want a dock.
        dock = {
          enabled = true;
          position = "bottom";
          auto_hide = true;
          background_opacity = 0.9;
          radius = 12;
          reserve_space = false;
          shadow = true;
          icon_size = 64;
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
      };
    };
  };
}
