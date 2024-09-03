{
  imports = [
    ../programs/home-manager.nix
  ];

  programs.systemd-services.environment = "venus";
  programs.git.userEmail = "kyokley@venus";
}
