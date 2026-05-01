{
  flake.modules.homeManager.venus = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [
      inputs.self.modules.homeManager.systemd-services
    ];

    programs = {
      git.settings.user.email = "kyokley@venus";
      zsh = {
        initContent = ''
          eval "$(direnv hook zsh)"
        '';
      };
    };

    home = {
      stateVersion = "23.11"; # Please read the comment before changing.
      packages = [
        pkgs.direnv
      ];
    };
  };
}
