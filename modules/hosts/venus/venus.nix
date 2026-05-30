{
  flake.modules.homeManager.venus = {
    inputs,
    pkgs,
    config,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      systemd-services
      syncthing
    ];

    programs = {
      git.settings.user.email = "kyokley@venus";
    };

    home = {
      stateVersion = "23.11"; # Please read the comment before changing.
    };
  };
}
