let
  host = "yokley@singularity";
in {
  flake.modules.homeManager.${host} = {inputs, ...}: {
    imports = with inputs.self.modules.homeManager; [
      systemd-services
      opencode
    ];

    programs = {
      git.settings.user.email = "${host}";
      nh.flake = "github:kyokley/dotfiles";
    };

    home = {
      stateVersion = "23.11"; # Please read the comment before changing.
      shellAliases.home-manager-switch = "nh home switch -c ${host}";
    };
  };
}
