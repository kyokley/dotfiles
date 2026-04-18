{
  pkgs,
  nixvim-output,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home-manager/home.nix
  ];

  programs = {
    git.settings.user.email = "kyokley@venus";

    zsh = {
      initContent = ''
        eval "$(direnv hook zsh)"
      '';
    };
  };

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-output}
    pkgs.direnv
  ];
}
