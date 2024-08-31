{ pkgs, ... }:
{
  programs.rofi.enable = true;
  programs.rofi.package = pkgs.rofi.override { plugins = [
    pkgs.rofi-emoji
    pkgs.rofi-power-menu
    pkgs.rofi-calc
  ]; };
  programs.rofi.extraConfig = {
      show-icons = true;
      modi = "drun,rofi-emoji,rofi-calc";
      kb-cancel = "Escape,Control+c,Control+bracketleft";
      drun-match-fields = "name";
  };
  programs.rofi.theme = ./fancy.rasi;
}
