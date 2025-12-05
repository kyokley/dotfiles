{pkgs, ...}: {
  home.packages = [
    pkgs.universal-ctags
  ];
  programs.git.settings.core.editor = "vim";

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
