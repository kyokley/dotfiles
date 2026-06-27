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
      "yokley@dioxygen" = mkHomeConfiguration {
        system = aarch64_darwin;
        hostName = "dioxygen";
      };

      "yokley@venus" = mkHomeConfiguration {
        hostName = "venus";
        nixvim-output = "minimal";
      };

      "yokley@almagest" = mkHomeConfiguration {
        hostName = "almagest";
      };

      "yokley@jupiter" = mkHomeConfiguration {
        hostName = "jupiter";
      };

      "yokley@singularity" = mkHomeConfiguration {
        hostName = "singularity";
        nixvim-output = "minimal";
      };
    };
  };
}
