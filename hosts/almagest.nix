{ pkgs, ... }:
{
  home.packages = [
    pkgs.docker-compose
  ];
  programs.nixvim.enable = false;
  programs.nixvim.installType = "minimal";

  programs.git.userEmail = "kyokley@almagest";
}
