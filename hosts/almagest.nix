{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
  ];

  programs.git.userEmail = "kyokley@almagest";
  programs.neovim = {
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
  };

  programs.nixvim = {
    enable = false;
    installType = "minimal";
  };
}
