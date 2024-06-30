{ pkgs, ... }:
{
  home.packages = [
    pkgs.docker-compose
  ];

  programs.systemd-services.environment = "almagest";

  programs.nixvim.enable = false;
  programs.nixvim.installType = "minimal";

  programs.git.userEmail = "kyokley@almagest";
}
