{
  programs.terminator = {
    enable = true;
    config = {
      profiles = {
        default = {
          font = "Hack Nerd Font Mono 16";
          use_system_font = false;
          scrollback_infinite = true;
          show_titlebar = true;
          title_font = "Hack Nerd Font Mono 14";
          title_use_system_font = false;
        };
        demo = {
          font = "Hack Nerd Font Mono 25";
          use_system_font = false;
        };
      };
      keybindings = {
        new_tab = "<Ctrl>T";
        next_tab = "<Ctrl>Tab";
        prev_tab = "<Shift><Ctrl>Tab";
        switch_to_tab_1 = "<Ctrl>1";
        switch_to_tab_2 = "<Ctrl>2";
        switch_to_tab_3 = "<Ctrl>3";
        switch_to_tab_4 = "<Ctrl>4";
        switch_to_tab_5 = "<Ctrl>5";
        switch_to_tab_6 = "<Ctrl>6";
        switch_to_tab_7 = "<Ctrl>7";
        switch_to_tab_8 = "<Ctrl>8";
        switch_to_tab_9 = "<Ctrl>9";
      };
    };
  };
}
