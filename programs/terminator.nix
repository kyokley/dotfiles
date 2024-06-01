{
  programs.terminator = {
    enable = true;
    config = {
      profiles.default.font = "Hack Nerd Font Mono 16";
      profiles.default.use_system_font = false;
      profiles.default.scrollback_infinite = true;
      profiles.demo.font = "Hack Nerd Font Mono 25";
      profiles.demo.use_system_font = false;
    };
  };
}
