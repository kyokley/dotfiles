{
  flake.modules.homeManager.common = {
    lib,
    fullName,
    pkgs,
    username,
    hostName,
    ...
  }: {
    home.packages = with pkgs; [
      lazyjj
      jjui
    ];
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = lib.mkDefault "${username}@${hostName}";
          name = lib.mkDefault fullName;
        };
      };
    };
  };
}
