let
  initialUser = "yokley";
in {
  den = {
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
  };
}
