{
  flake.modules.homeManager."yokley@venus" = {inputs, ...}:{
    imports = with inputs.self.modules.homeManager; [
      systemd-services
      syncthing
      distributedBuilds
    ];

    home = {
      stateVersion = "23.11"; # Please read the comment before changing.
    };
  };
}
