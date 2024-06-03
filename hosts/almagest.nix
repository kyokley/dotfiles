{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
  ];

  programs.git.userEmail = "kyokley@almagest";
  programs.neovim.vimAlias = true;

  programs.nixvim = {
    enable = false;
    installType = "minimal";
  };
}
