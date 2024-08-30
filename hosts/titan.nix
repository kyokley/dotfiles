{
  programs.systemd-services.environment = "titan";
  programs.git.userEmail = "kyokley@titan";
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}

