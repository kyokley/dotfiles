{
  flake.modules.homeManager.singularity = {inputs, ...}: {
    imports = [
      inputs.self.modules.homeManager.systemd-services
    ];

    programs.git.settings.user.email = "kyokley@singularity";

    home.stateVersion = "23.11"; # Please read the comment before changing.
  };
}
