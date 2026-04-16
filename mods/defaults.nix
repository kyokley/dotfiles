{
  den = {
    schema.user.classes = lib.mkDefault ["homeManager"];

    default = {
      nixos.system.stateVersion = "23.11";

      homeManager.home.stateVersion = "23.11";
    };
  };
}
