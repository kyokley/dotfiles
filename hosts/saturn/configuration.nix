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

  environment.systemPackages = with pkgs; [
    gnome-keyring
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
        if [ $(DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u yokley ${pkgs.xorg.xrandr}/bin/xrandr | grep -P '\d+x\d+\+\d+\+\d+' | wc -l) = "1" ]; then
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
