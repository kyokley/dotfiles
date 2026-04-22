{
  inputs,
  pkgs,
  constants,
  generators,
  ...
}: let
  inherit (constants.systems) aarch64_darwin;
  inherit (generators) mkHomeConfiguration;
in {
  flake.homeConfigurations = {
    dioxygen = mkHomeConfiguration {
      system = aarch64_darwin;
      hostName = "dioxygen";
    };

    venus = mkHomeConfiguration {
      hostName = "venus";
      nixvim-output = "minimal";
    };

    almagest = mkHomeConfiguration {
      hostName = "almagest";
      nixvim-output = "withoutCopilot";
    };

    jupiter = mkHomeConfiguration {
      hostName = "jupiter";
    };

    singularity = mkHomeConfiguration {
      hostName = "singularity";
      nixvim-output = "minimal";
    };
  };

  perSystem = {
    dev = {
      home = {
        packages = [
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

        file = {
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
      };

      programs.zsh = {
        initContent = ''
          eval "$(direnv hook zsh)"
        '';
      };
    };
  };
}
