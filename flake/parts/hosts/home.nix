{
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
}
