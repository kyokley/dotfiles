{
  flake.modules = {
    darwin.common = {username, ...}: {
      programs.zsh.enable = true;
      ids.gids.nixbld = 30000;

      users.users.${username} = {
        home = "/Users/${username}";
        uid = 501;
      };

      nix = {
        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
        };
        settings = {
          trusted-users = [
            "root"
            "${username}"
          ];
          download-buffer-size = 524288000;
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
        };
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
