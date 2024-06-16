{ pkgs, ... }:
{
  home.homeDirectory = "/Users/yokley";

  home.packages = [
    pkgs.devenv
  ];
}
