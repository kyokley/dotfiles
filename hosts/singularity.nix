{
  imports = [
    ../programs/home-manager.nix
  ];

  programs.systemd-services.environment = "singularity";

  programs.git.userEmail = "kyokley@singularity";
}
