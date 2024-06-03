{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
  ];

  programs.nixvim.enable = false;
  programs.git.userEmail = "kyokley@venus";
  programs.neovim = {
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
  };
}
