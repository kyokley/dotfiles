{ pkgs, ... }:
{
  home.packages = [
    pkgs.docker-compose
  ];
  programs.nixvim.enable = false;
  programs.git.userEmail = "kyokley@almagest";
}
