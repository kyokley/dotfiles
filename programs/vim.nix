{pkgs, ...}: let
  docker-vim = pkgs.writeShellScriptBin "dvim" ''
    docker run --rm -it -v $(pwd):/files -w /files kyokley/nixvim $@
  '';
in {
  home.packages = [
    pkgs.universal-ctags
    docker-vim
  ];

  programs.git.extraConfig.core.editor = "vim";

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
