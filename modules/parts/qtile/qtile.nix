{inputs, ...}: {
  flake.modules = {
    homeManager = {
      qtile = {
        pkgs,
        lib,
        ...
      }: let
        force-lock-screen = pkgs.writeShellScriptBin "force-lock-screen" ''
          PATH=$PATH:${lib.makeBinPath [pkgs.betterlockscreen]}
          ${pkgs.betterlockscreen}/bin/betterlockscreen --lock
        '';
      in {
        home.packages = [
          force-lock-screen
        ];

        file = {
          ".config/qtile" = {
            source = ./.;
            target = ".config/qtile";
            recursive = true;
          };
        };
      };
    };

    nixos = {
      qtile = {lib, ...}: {
        services = {
          xserver.windowManager.qtile = {
            enable = true;
            extraPackages = python3Packages:
              with python3Packages; [
                requests
                pillow
                pywal
                python-dateutil
              ];
          };
          displayManager.defaultSession = lib.mkDefault "qtile";
        };
      };
    };
  };
}
