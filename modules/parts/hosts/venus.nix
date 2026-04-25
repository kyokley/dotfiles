{
  flake.modules.homeManager.venus = {
    programs.git.settings.user.email = "kyokley@venus";

    home.stateVersion = "23.11"; # Please read the comment before changing.
  };
}
