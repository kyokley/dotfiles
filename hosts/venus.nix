{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
  ];

  programs.nixvim.enable = false;
  programs.git.userEmail = "kyokley@venus";
  programs.zsh.shellGlobalAliases = {
    vim = "nvim";
  };
}
