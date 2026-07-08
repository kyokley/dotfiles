{inputs, ...}: {
  flake.modules.homeManager.common = {
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      shortcut = "a";
    };
  };
}
