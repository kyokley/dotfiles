{ pkgs, lib, ... }:
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
      lidEventCommands =
      ''
        export PATH=$PATH:${lib.makeBinPath [ pkgs.nix ]}

        if [ $(xrandr | grep connected | wc -l) -eq 1 ]; then
          lid_state=$(cat /proc/acpi/button/lid/LID0/state | ${pkgs.gawk}/bin/awk '{print $NF}')
          if [ $lid_state = "closed" ]; then
            systemctl suspend
            DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u yokley ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork
          fi
        fi
      '';
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
