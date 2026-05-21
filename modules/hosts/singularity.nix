{
  flake.modules.homeManager.singularity = {inputs, ...}: {
    imports = with inputs.self.modules.homeManager; [
      systemd-services
      opencode
    ];

    programs.git.settings.user.email = "kyokley@singularity";

    home.stateVersion = "23.11"; # Please read the comment before changing.
  };
}
