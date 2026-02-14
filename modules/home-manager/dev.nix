{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    pkgs.gnumake
    pkgs.ripgrep
    pkgs.tig
    pkgs.jq
    pkgs.devenv
    pkgs.direnv
    pkgs.ragenix
    inputs.usql.packages.${pkgs.stdenv.hostPlatform.system}.default
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
