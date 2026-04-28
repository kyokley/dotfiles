{
  flake.modules.nixos.flatpak = {pkgs, ...}: {
    services.flatpak.enable = true;

    xdg = {
      portal = {
        enable = false;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config.common.default = "*";
      };
    };
  };
}
