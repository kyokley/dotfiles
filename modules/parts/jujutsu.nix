{
  flake.modules.homeManager.common = {
    fullName,
    email,
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.lazyjj
    ];
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          inherit email;
          name = fullName;
        };
      };
    };
  };
}
