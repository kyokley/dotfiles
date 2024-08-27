{
  programs.systemd-services.environment = "venus";
  programs.git.userEmail = "kyokley@venus";
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
