{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
  ];

  programs.nixvim.enable = false;
  programs.git.userEmail = "kyokley@almagest";
  programs.zsh.shellGlobalAliases = {
    vim = "nvim";
  };
}
