{pkgs, ...}: {
  home.packages = [
    pkgs.rofi-power-menu
  ];

  programs.rofi.enable = true;
  programs.rofi.package = pkgs.rofi.override {
    plugins = [
      pkgs.rofi-emoji
      pkgs.rofi-calc
    ];
  };
  programs.rofi.extraConfig = {
    show-icons = true;
    kb-cancel = "Escape,Control+bracketleft";
    drun-match-fields = "name";
  };
  programs.rofi.theme = ./fancy.rasi;
}
