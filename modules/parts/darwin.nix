{
  flake.modules = {
    darwin.common = {username, ...}: {
      nixpkgs.config.allowBroken = true;

      # Disable documentation to avoid nixos-render-docs compatibility
      # issues (--toc-depth removed in latest nixpkgs, nix-darwin#718).
      documentation.enable = false;

      # Also disable darwin-uninstaller, since it creates a separate
      # nix-darwin evaluation that still builds docs (--toc-depth error).
      system.tools.darwin-uninstaller.enable = false;

      # Bootout all home-manager LaunchAgents before home-manager's activation
      # tries to re-bootstrap them. Home-manager only sleeps 1s between bootout
      # and bootstrap, which isn't enough for services with slow teardown
      # (syncthing, etc.), causing "I/O error (code 5)". We give them 5s.
      system.activationScripts.preHomeManagerLaunchAgents = {
        deps = [ "std" ];
        text = ''
          USER_ID=$(id -u "${username}")
          /bin/launchctl list "gui/$USER_ID" 2>/dev/null \
            | awk '/org\.nix-community\.home\./ {print $3}' \
            | while read -r agent; do
                /bin/launchctl bootout "gui/$USER_ID/$agent" 2>/dev/null || true
              done
          sleep 5
        '';
      };

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
      home.homeDirectory = "/Users/${username}";

      nixpkgs = {
        overlays = [
          (final: prev: {
            direnv = prev.direnv.overrideAttrs (_: {
              doCheck = false;
            });
          })
        ];
        config = {
          allowBroken = true;
          allowUnfree = true;
          allowUnfreePredicate = pkg: true;
        };
      };

      services.home-manager.autoUpgrade.enable = false;
    };
  };
}
