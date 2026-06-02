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
        home = {
          packages = [
            force-lock-screen
            pkgs.librsvg
          ];

          file = {
            ".config/qtile" = {
              source = ./.;
              target = ".config/qtile";
              recursive = true;
            };
          };
          sessionVariables = {
            GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
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
