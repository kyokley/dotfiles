{
  flake.modules = {
    darwin.common = {
    };

    homeManager.darwin = {username, ...}: {
      home = {
        homeDirectory = "/Users/${username}";
      };

      nixpkgs.overlays = [
        (final: prev: {
          direnv = prev.direnv.overrideAttrs (_: {
            doCheck = false;
          });
        })
      ];

      services = {
        home-manager.autoUpgrade.enable = false;
      };
    };
  };
}
