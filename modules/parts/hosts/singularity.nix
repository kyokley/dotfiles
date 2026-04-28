{
  flake.modules.homeManager.singularity = {
    programs.git.settings.user.email = "kyokley@singularity";

    home.stateVersion = "23.11"; # Please read the comment before changing.
  };
}
