{
  flake.modules.homeManager.picom = {pkgs, username, ...}: let
        toggle-picom = pkgs.writeScriptBin "toggle-picom" ''
          #!${pkgs.stdenv.shell}
          if systemctl --user status picom | grep 'running'; then
            systemctl --user stop picom
          else
            systemctl --user start picom
          fi
        '';
        homeDir = "/home/${username}";
  in {
    home = {
      packages = [
        toggle-picom
      ];

      file = {
        ".config/picom/picom-custom.conf" = {
          source = ./picom.conf;
        };
      };
    };

    services = {
      picom = {
        enable = false;
        extraArgs = ["--config=${homeDir}/.config/picom/picom-custom.conf"];
      };
    };
  };
}
