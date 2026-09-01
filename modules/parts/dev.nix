{inputs, ...}: {
  flake.modules.homeManager = {
    dev = {
      pkgs,
      lib,
      config,
      ...
    }: let
      AGE_DIR = "${config.home.homeDirectory}/.config/age";
      AGE_IDENTITY_FILE = "${AGE_DIR}/plugin-identity.txt";
      AGE_KEYS_FILE = "${AGE_DIR}/keys.txt";
      init-age = pkgs.writeShellApplication {
        name = "init-age";
        text = ''
          mkdir -p "${AGE_DIR}"
          ${pkgs.age}/bin/age-keygen -pq -o "${AGE_KEYS_FILE}"
          ${pkgs.age}/bin/age-plugin-pq -identity -o "${AGE_IDENTITY_FILE}" "${AGE_KEYS_FILE}"
        '';
      };
      show-age = pkgs.writeShellApplication {
        name = "show-age";
        text = ''
          grep 'public key' "${AGE_KEYS_FILE}" | awk -F' ' '{print $NF}'
        '';
      };
    in {
      home.packages = [
        pkgs.age
        init-age
        show-age
        pkgs.gnumake
        pkgs.ripgrep
        pkgs.tig
        pkgs.jq
        pkgs.devenv
        pkgs.direnv
        inputs.usql.packages.${pkgs.stdenv.hostPlatform.system}.default
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux
        [inputs.ai-browser.packages.${pkgs.stdenv.hostPlatform.system}.default];

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
          eval "$(devenv hook zsh)"
        '';
      };
    };
  };
}
