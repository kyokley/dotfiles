{ pkgs, lib, ... }:
{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Not sure if these are needed to fix docker networking issues when tailscale
  # exit nodes are active
  # boot.kernel.sysctl = {
  #   "net.ipv4.ip_forward" = true;
  #   "net.ipv6.conf.all.forwarding" = true;
  # };

  networking.hostName = "mars"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  sound.enable = true;

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    gnome.gnome-keyring
  ];

  services = {
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

        lid_state=$(cat /proc/acpi/button/lid/LID0/state | ${pkgs.gawk}/bin/awk '{print $NF}')
        if [ $lid_state = "closed" ]; then
          systemctl suspend
          DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u yokley ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork
        fi
      '';

      powerEventCommands =
      ''
        systemctl suspend
        DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u yokley ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork
      '';
    };
  };

  system.stateVersion = "24.05"; # Don't touch me!
}
