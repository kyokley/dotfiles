{
  flake.modules = {
    darwin.common = {username, ...}: {
      programs.zsh.enable = true;
      users.users.${username} = {
        home = "/Users/${username}";
        uid = 501;
      };
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
