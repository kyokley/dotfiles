{generators, ...}: let
  inherit (generators) mkNixosConfiguration;
in {
  flake.nixosConfigurations = {
    mars = mkNixosConfiguration {
      hostName = "mars";
    };

    mercury = mkNixosConfiguration {
      hostName = "mercury";
    };
  };
}
