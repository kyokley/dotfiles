{
  flake.modules.homeManager.dioxygen = {
    inputs,
    pkgs,
    lib,
    username,
    config,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      dev
      distributedBuilds
      opencode
      syncthing
    ];

    home = {
      homeDirectory = "/Users/${username}";
      stateVersion = "24.05";
    };

    programs.git.settings.alias = {
      select = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | choose | xargs -r git switch'';
    };

    nixpkgs.overlays = [
      (final: prev: {
        direnv = prev.direnv.overrideAttrs (_: {
          doCheck = false;
        });
      })
    ];

    age.secrets = {
      dioxygen-syncthing-key.file = ../../parts/_secrets/syncthing/dioxygen/key.age;
      dioxygen-syncthing-cert.file = ../../parts/_secrets/syncthing/dioxygen/cert.age;
    };

    services = {
      home-manager.autoUpgrade.enable = false;

      syncthing = {
        cert = "${config.age.secrets.dioxygen-syncthing-cert.path}";
        key = "${config.age.secrets.dioxygen-syncthing-key.path}";
      };
    };

    systemd.user.services.syncthing.Unit = {
      After = ["agenix.service"];
      Wants = ["agenix.service"];
    };
  };
}
