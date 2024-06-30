{
  programs.systemd-services.environment = "venus";
  programs.nixvim.enable = false;
  programs.nixvim.installType = "minimal";
  programs.git.userEmail = "kyokley@venus";
}
