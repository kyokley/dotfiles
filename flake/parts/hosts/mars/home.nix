{
  flake.modules = {
    homeManager.mars = {
      pkgs,
      lib,
      username,
      inputs,
      ...
    }: let
      cd_paths = [
        "/home/${username}/workspace"
      ];
    in {
      imports = [
        inputs.self.modules.homeManager.nixos
        inputs.self.modules.homeManager.opencode
      ];

      programs.git.settings.user.email = "kyokley@mars";

      home = {
        sessionVariables = {
          QTILE_NET_INTERFACE = "wlp1s0";
          CDPATH = lib.concatStringsSep ":" cd_paths;
        };

        packages = [
          pkgs.ollama
          pkgs.brightnessctl
          pkgs.mattermost-desktop
          pkgs.lutris
          pkgs.steam
        ];

        stateVersion = "24.05"; # Don't touch me!
      };
    };
  };
}
