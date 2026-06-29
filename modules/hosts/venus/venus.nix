{
  flake.modules.homeManager."yokley@venus" = {
    inputs,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      systemd-services
      syncthing
      distributedBuilds
    ];

    programs = {
      git.settings.user.email = "kyokley@venus";
    };

    home = {
      stateVersion = "23.11"; # Please read the comment before changing.
    };
  };
}
