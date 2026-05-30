{
  flake.modules.homeManager.venus = {
    inputs,
    pkgs,
    config,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      systemd-services
      syncthing
    ];

    programs = {
      git.settings.user.email = "kyokley@venus";
    };

    home = {
      stateVersion = "23.11"; # Please read the comment before changing.
    };

    age.secrets = {
      venus-syncthing-key.file = ../../parts/_secrets/syncthing/venus/key.age;
      venus-syncthing-cert.file = ../../parts/_secrets/syncthing/venus/cert.age;
    };
    services = {
      syncthing = {
        cert = "${config.age.secrets.dioxygen-syncthing-cert.path}";
        key = "${config.age.secrets.dioxygen-syncthing-key.path}";
      };
    };
  };
}
