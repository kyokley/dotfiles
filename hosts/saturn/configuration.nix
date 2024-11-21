{ pkgs, ... }:
{
  imports = [
      ../../programs/openconnect.nix
  ];

  networking.openconnect.interfaces.openconnect0.passwordFile = /var/lib/secrets/openconnect-passwd;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "saturn"; # Define your hostname.

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = true;
  };

  sound.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.gnome-keyring
  ];

  services = {
    tailscale.enable = false;
    logind = {
      lidSwitch = "ignore";
      extraConfig = ''
        HandlePowerKey=ignore
        HandleLidSwitch=ignore
      '';
    };
    acpid = {
      enable = true;
      powerEventCommands =
      ''
        systemctl suspend
        DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u yokley ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork
      '';
    };
  };

  networking.extraHosts = ''
    192.168.50.75 jupiter
  '';

  system.stateVersion = "24.05"; # Don't touch me!
}
