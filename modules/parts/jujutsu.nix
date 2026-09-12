{
  flake.modules.homeManager.common = {
    fullName,
    email,
    ...
  }: {
    programs.jujutsu = {
      enable = true;
      settings = {
        inherit fullName email;
      };
    };
  };
}
