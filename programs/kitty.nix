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
      scrollback_pager_history_size = 1000;
      scrollback_lines = -1;
      strip_trailing_spaces = "smart";
      enable_audio_bell = "no";
      visual_bell_duration = "0.25 linear";
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_bar_min_tabs = 1;
      tab_bar_align = "center";
      notify_on_cmd_finish = ''invisible 10.0 command dunstify "job finished => %s" "%c"'';
    };
    extraConfig = ''
      cursor_trail_decay 0.1 0.4
      map ctrl+t new_tab
      map ctrl+tab next_tab
      map ctrl+shift+tab previous_tab
      map ctrl+1 first_window
      map ctrl+2 second_window
      map ctrl+3 third_window
      map ctrl+4 fourth_window
      map ctrl+5 fifth_window
      map ctrl+6 sixth_window
      map ctrl+7 seventh_window
      map ctrl+8 eigth_window
      map ctrl+9 ninth_window
    '';
  };
}
