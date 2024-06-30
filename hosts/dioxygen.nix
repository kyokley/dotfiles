{ pkgs, ... }:
{
  programs.systemd-services.environment = "dioxygen";

  home.homeDirectory = "/Users/yokley";

  home.packages = [
    pkgs.devenv
  ];

  services.home-manager.autoUpgrade.enable = false;
}
