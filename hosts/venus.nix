{
  imports = [
    ../home.nix
  ];

  programs.systemd-services.environment = "venus";
  programs.git.userEmail = "kyokley@venus";

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
