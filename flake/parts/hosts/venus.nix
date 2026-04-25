{
  flake.modules.homeManager.venus = {
    pkgs,
    nixvim-output,
    inputs,
    ...
  }: {
    programs.git.settings.user.email = "kyokley@venus";

    home.stateVersion = "23.11"; # Please read the comment before changing.

    home.packages = [
      inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-output}
    ];
  };
}
