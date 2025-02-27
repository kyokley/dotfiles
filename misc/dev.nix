{
  pkgs,
  pkgs-unstable,
  nixvim,
  ...
}: {
  home.packages = [
    pkgs.gnumake
    pkgs.ripgrep
    pkgs.tig
    pkgs.jq
    pkgs-unstable.devenv
    nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.direnv
  ];

  programs.zsh = {
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
  };
}
