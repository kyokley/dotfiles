{
  constants,
  generators,
  ...
}: let
  inherit (constants) defaultUsername;
  inherit (constants.systems) aarch64_darwin;
  inherit (generators) mkHomeConfiguration mkNixosConfiguration;
in {
  flake = {
    nixosConfigurations = rec {
      mars = mkNixosConfiguration {
        hostName = "mars";
      };

      mercury = mkNixosConfiguration {
        hostName = "mercury";
      };

      default = mars;
    };

    homeConfigurations = {
      "${defaultUsername}@dioxygen" = mkHomeConfiguration {
        system = aarch64_darwin;
        hostName = "dioxygen";
      };

      "${defaultUsername}@venus" = mkHomeConfiguration {
        hostName = "venus";
        nixvim-output = "minimal";
      };

      "${defaultUsername}@almagest" = mkHomeConfiguration {
        hostName = "almagest";
      };

      "${defaultUsername}@jupiter" = mkHomeConfiguration {
        hostName = "jupiter";
      };

      "${defaultUsername}@singularity" = mkHomeConfiguration {
        hostName = "singularity";
        nixvim-output = "minimal";
      };

      # Output added to support nixd
      default = mkHomeConfiguration {
        hostName = "mars";
      };
    };
  };
}
