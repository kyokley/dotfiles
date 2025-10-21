{
  pkgs,
  pkgs-unstable,
  usql,
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
    usql.defaultPackage.${pkgs.stdenv.hostPlatform.system}
  ];

  home.file = {
    pdbpp = {
      enable = true;
      target = ".pdbrc.py";
      text = ''
        import pdb
        class Config(pdb.DefaultConfig):
            sticky_by_default = True
      '';
    };
  };

  programs.zsh = {
    initContent = ''
      eval "$(direnv hook zsh)"
    '';
  };
}
