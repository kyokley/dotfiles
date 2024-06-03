{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovim
  ];

  programs.nixvim.enable = false;
  home.homeDirectory = "/home/yokley";
  programs.git.userEmail = "kyokley@venus";
}
