{
  inputs,
  den,
  lib,
  ...
}: let
  initialUser = "yokley";
in {
  imports = [inputs.den.flakeModule];

  den = {
    schema.user.classes = lib.mkDefault ["homeManager"];
    hosts = {
      x86_64-linux = {
        mars.users.${initialUser} = {};
        mercury.users.${initialUser} = {};
      };
    };

    homes = {
      x86_64-linux.${initialUser} = {};
      aarch64_darwin.${initialUser} = {};
    };

    aspects = {
      "${initialUser}" = {};
      mars = {};
      mercury = {};
    };
  };
}
