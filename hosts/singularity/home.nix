{
  pkgs,
  nixvim-output,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home-manager/home.nix
  ];

  programs.git.settings.user.email = "kyokley@singularity";

  home.packages = [
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-output}
  ];

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
