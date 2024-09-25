{
  imports = [
    ../home.nix
  ];

  programs.systemd-services.environment = "singularity";

  programs.git.userEmail = "kyokley@singularity";
}
