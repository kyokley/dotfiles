{
  flake.modules.homeManager.cachix = {
    lib,
    config,
    ...
  }: {
    age.secrets = {
      cachix = {
        file = ./_secrets/cachix.age;
      };
    };

    programs.zsh.prezto.extraConfig = lib.mkAfter ''
      export CACHIX_AUTH_TOKEN=$(cat ${config.age.secrets.cachix.path})
    '';
  };
}
