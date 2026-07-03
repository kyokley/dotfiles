{
  flake.modules = {
    nixos.common = {
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

    homeManager.common = {
      inputs,
      pkgs,
      lib,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        systemd.enable = false;

        plugins = [
          # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.wayle
        ];

        settings = {
          mod = {
            _var = "SUPER";
          };

          config = {
            general = {
              gaps_in = 5;
              gaps_out = 20;
              border_size = 2;
            };

            decoration = {
              rounding = 10;
            };
          };

          bind = [
            {
              _args = [
                (lib.generators.mkLuaInline "mod .. \" + Q\"")
                (lib.generators.mkLuaInline "hl.dsp.window.close()")
                {locked = true;}
              ];
            }
            {
              _args = [
                "SUPER + RETURN"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
              ];
            }
            {
              _args = [
                "ALT + R"
                (lib.generators.mkLuaInline "hl.dsp.submap(\"resize\")")
              ];
            }
          ];

          define_submap = {
            _args = [
              "resize"
              (lib.generators.mkLuaInline "function()\n  hl.bind(\"right\", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })\n  hl.bind(\"left\", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })\n  hl.bind(\"escape\", hl.dsp.submap(\"reset\"))\nend")
            ];
          };

          window_rule = {
            match.class = "kitty";
            border_size = 2;
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
    };
  };
}
