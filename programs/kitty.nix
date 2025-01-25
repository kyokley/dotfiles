{
  programs.kitty = {
    enable = true;
    font = {
      name = "Hack Nerd Font Mono";
      size = 16;
    };
    shellIntegration = {
      enableZshIntegration = true;
      mode = "no-cursor";
    };
    themeFile = "Dark_Pastel";
    settings = {
      cursor_shape = "block";
      cursor_trail = 3;
    };
    extraConfig = ''
      cursor_trail_decay 0.1 0.4
    '';
  };
}
