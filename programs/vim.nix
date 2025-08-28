{pkgs, ...}: {
  home.packages = [
    pkgs.universal-ctags
  ];
  programs.git.extraConfig.core.editor = "vim";

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
