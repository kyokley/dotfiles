{
  programs.rofi.enable = true;
  programs.rofi.extraConfig = {
      modi = "drun,combi,run";
      show-icons = true;
      combi-modi = "drun,run";
      kb-cancel = "Escape,Control+c,Control+bracketleft";
      drun-match-fields = "name";
  };
  programs.rofi.theme = ./fancy.rasi;
}
