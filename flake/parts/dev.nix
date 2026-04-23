{inputs, ...}: {
  flake.modules.homeManager = rec {
    _dev_default = {pkgs, ...}: {
      home.packages = [
        pkgs.gnumake
        pkgs.ripgrep
        pkgs.tig
        pkgs.jq
        pkgs.devenv
        pkgs.direnv
        pkgs.ragenix
        pkgs.gh
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
    };

    dioxygen = _dev_default;
    mars = _dev_default;
  };
}
