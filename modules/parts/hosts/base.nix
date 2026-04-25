{
  constants,
  generators,
  ...
}: let
  inherit (constants.systems) aarch64_darwin;
  inherit (generators) mkHomeConfiguration mkNixosConfiguration;
in {
  flake = {
    nixosConfigurations = {
      mars = mkNixosConfiguration {
        hostName = "mars";
      };

      mercury = mkNixosConfiguration {
        hostName = "mercury";
      };
    };

    homeConfigurations = {
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

    modules = {
      homeManager = {
        common = {lib, ...}: {home.stateVersion = lib.mkDefault "23.11";};
        mercury.home.stateVersion = "24.05";
        mars.home.stateVersion = "24.05";
        dioxygen.home.stateVersion = "24.05";
      };

      nixos = {
        common.system.stateVersion = "24.05";
      };
    };
  };
}
