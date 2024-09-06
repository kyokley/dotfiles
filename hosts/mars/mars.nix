{
    programs.systemd-services.environment = "mars";

    home.homeDirectory = "/home/yokley";
    programs.git.userEmail = "kyokley@mars";

    imports = [
        ../../programs/nixos/nixos.nix
    ];

  home.file = {
    ".config/nixos/configuration.nix" = {
      source = ./configuration.nix;
    };
  };
}
