{
  flake.modules = {
    nixos.hyprland = {
      inputs,
      pkgs,
      ...
    }: {
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
    };

    homeManager.hyprland = {
      inputs,
      pkgs,
      lib,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        configType = "lua";
        systemd.enable = false;

        plugins = [
          # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.wayle
        ];

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
            ws =
              builtins.genList (x: let
                ws_id = toString (x + 1);
                key =
                  if x == 9
                  then "0"
                  else ws_id;
              in [
                {
                  _args = [
                    (lib.generators.mkLuaInline ''mod .. " + ${key}"'')
                    (lib.generators.mkLuaInline ''function() local ws = hl.get_active_workspace(); if ws and ws.id == ${ws_id} then hl.dispatch(hl.dsp.focus({ workspace = "previous" })) else hl.dispatch(hl.dsp.focus({ workspace = "${ws_id}" })) end end'')
                  ];
                }
                {
                  _args = [
                    (lib.generators.mkLuaInline ''mod .. " + SHIFT + ${key}"'')
                    (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "${ws_id}" })'')
                  ];
                }
              ])
              10;
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
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("rofi -show drun")'')
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
                  (lib.generators.mkLuaInline ''mod .. " + K"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("cycleprev")'')
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
            ]
            ++ (builtins.concatLists ws);

          define_submap = {
            _args = [
              "resize"
              (lib.generators.mkLuaInline "function()\n  hl.bind(\"right\", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })\n  hl.bind(\"left\", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })\n  hl.bind(\"escape\", hl.dsp.submap(\"reset\"))\nend")
            ];
          };

          window_rule = {
            match.class = "kitty";
            border_size = 3;
          };

          on = {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline "function()\n  hl.exec_cmd(\"waybar\")\nend")
            ];
          };
        };
      };
      programs = {
        kitty.enable = true;
      };

      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      services.wpaperd = {
        enable = true;
        settings = {
          eDP-1 = {
            path = "/home/yokley/Pictures/wallpapers";
          };
        };
      };
    };
  };
}
