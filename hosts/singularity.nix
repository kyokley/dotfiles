{
  imports = [
    ../home.nix
  ];

  programs.systemd-services.environment = "singularity";

  programs.git.userEmail = "kyokley@singularity";

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
