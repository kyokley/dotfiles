{ pkgs, ... }:
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

  systemd.services = {
    lock-before-sleeping = {
      restartIfChanged = false;
      unitConfig = {
        Description = "Helper service to bind locker to sleep.target";
      };
      serviceConfig = {
        ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen --lock";
        Type = "simple";
      };
      before = [
        "pre-sleep.service"
      ];
      wantedBy= [
        "pre-sleep.service"
      ];
      environment = {
        DISPLAY = ":0";
        XAUTHORITY = "/home/yokley/.Xauthority";
      };
    };
  };

  system.stateVersion = "24.05"; # Don't touch me!
}
