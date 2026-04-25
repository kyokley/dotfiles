{
  flake.modules.homeManager.dioxygen = {
    inputs,
    pkgs,
    lib,
    username,
    ...
  }: {
    imports = [
      inputs.self.modules.homeManager.opencode
    ];

    programs.systemd-services.enable = false;

    home = {
      homeDirectory = "/Users/${username}";
      stateVersion = "24.05";
    };

    services.home-manager.autoUpgrade.enable = false;

    programs.git.settings.alias = {
      select = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | choose | xargs -r git switch'';
    };
  };
}
