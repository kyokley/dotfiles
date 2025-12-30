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
      tab_separator = ''" | "'';
      tab_bar_min_tabs = 1;
      tab_bar_align = "center";
      tab_title_template = " {index} : {title} ";
      # Zsh doesn't seem to set the cmdline var correctly for Kitty
      # Re-enable notifications once this functionality is fixed
      # notify_on_cmd_finish = ''invisible 10.0 command dunstify "job finished => %s" "%c"'';
      # notify_on_cmd_finish = ''unfocused 5.0 command dunstify "%c job finished with status: %s"'';
      active_tab_foreground = "#2c7dff";
      active_tab_background = "#000";
      active_tab_font_style = "bold-italic";
      inactive_tab_foreground = "#3e3e4a";
      inactive_tab_background = "#000";
      inactive_tab_font_style = "normal";
    };
    extraConfig = ''
      cursor_trail_decay 0.1 0.4
      map ctrl+t new_tab_with_cwd
      map ctrl+tab next_tab
      map ctrl+shift+tab previous_tab
      map ctrl+1 goto_tab 1
      map ctrl+2 goto_tab 2
      map ctrl+3 goto_tab 3
      map ctrl+4 goto_tab 4
      map ctrl+5 goto_tab 5
      map ctrl+6 goto_tab 6
      map ctrl+7 goto_tab 7
      map ctrl+8 goto_tab 8
      map ctrl+9 goto_tab 9
    '';
  };
}
