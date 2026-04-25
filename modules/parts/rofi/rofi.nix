{
  flake.modules.homeManager.rofi = {pkgs, ...}: {
    home.packages = [
      pkgs.rofi-power-menu
    ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi.override {
        plugins = [
          pkgs.rofi-emoji
          pkgs.rofi-calc
        ];
      };
      extraConfig = {
        show-icons = true;
        kb-cancel = "Escape,Control+bracketleft";
        drun-match-fields = "name";
      };
      theme = ./fancy.rasi;
    };
  };
}
