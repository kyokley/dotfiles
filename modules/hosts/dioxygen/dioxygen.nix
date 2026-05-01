{
  flake.modules.homeManager.dioxygen = {
    inputs,
    pkgs,
    lib,
    username,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      dev
      distributedBuilds
      opencode
    ];

    home = {
      homeDirectory = "/Users/${username}";
      stateVersion = "24.05";
    };

    services.home-manager.autoUpgrade.enable = false;

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
  };
}
