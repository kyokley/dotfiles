{
  programs.systemd-services.environment = "singularity";

  programs.git.userEmail = "kyokley@singularity";
  programs.nixvim.enable = false;
}
