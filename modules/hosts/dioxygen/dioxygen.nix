{
  flake.modules.homeManager."yokley@dioxygen" = {
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

    services = {
      home-manager.autoUpgrade.enable = false;
    };
  };
}
