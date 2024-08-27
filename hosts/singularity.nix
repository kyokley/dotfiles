{
  programs.systemd-services.environment = "singularity";

  programs.git.userEmail = "kyokley@singularity";
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
