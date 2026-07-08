let
  mkGdkPixbufLoadersCache = pkgs: let
    gdkPixbufLoaderDir = "${pkgs.gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders";
    rsvgLoaderDir = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders";
  in
    pkgs.runCommand "qtile-gdk-pixbuf-loaders-cache" {} ''
      mkdir -p "$out/lib/gdk-pixbuf-2.0/2.10.0"
      ${pkgs.gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders \
        ${gdkPixbufLoaderDir}/*.so \
        ${rsvgLoaderDir}/*.so \
        > "$out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    '';
in {
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
        gdkPixbufLoadersCache = mkGdkPixbufLoadersCache pkgs;
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
            GDK_PIXBUF_MODULE_FILE = "${gdkPixbufLoadersCache}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
          };
        };
      };
    };

    nixos = {
      qtile = {
        lib,
        pkgs,
        ...
      }: let
        gdkPixbufLoadersCache = mkGdkPixbufLoadersCache pkgs;
      in {
        environment.sessionVariables = {
          GDK_PIXBUF_MODULE_FILE = "${gdkPixbufLoadersCache}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
        };

        services = {
          xserver.windowManager.qtile = {
            enable = true;
            package = pkgs.python3.pkgs.qtile.overrideAttrs (_: {
              doInstallCheck = false;
              dontUsePytestCheck = true;
            });
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
