{
  programs.terminator = {
    enable = true;
    config.profiles = {
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
  };
}
