{pkgs, ...} @ inputs: {
  imports = [
    ../../modules/home-manager/home.nix
  ];

  programs.git.settings.user.email = "kyokley@venus";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${inputs.nixvim-output}
  ];
}
