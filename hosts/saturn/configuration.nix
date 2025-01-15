{ pkgs, ... }:
{
  imports = [
      ../../programs/openconnect/ocna.nix
      ../../programs/openconnect/no-proxy.nix
      ../../programs/nixos/laptop.nix
      ../../programs/clamav.nix

      # Import SSH
      ./ssh.nix
  ];

  users.users.yokley.openssh.authorizedKeys = {
    keyFiles = [
      ../mars/mars.pub
      ../dioxygen/dioxygen.pub
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "saturn"; # Define your hostname.

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = false;
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p tcp --dport 10443 -j REJECT
    iptables -N log443
    iptables -A INPUT -p tcp --dport 10443 -j REJECT
    iptables -A log443 -j ACCEPT
    iptables-save
  '';

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];

  virtualisation.virtualbox.host = {
    enable = true;
    enableKvm = true;
    enableExtensionPack = true;
    addNetworkInterface = false;
  };
  virtualisation.virtualbox.guest = {
    enable = true;
    dragAndDrop = true;
  };
  users.extraGroups.vboxusers.members = [ "yokley" ];

  networking.extraHosts = ''
    192.168.50.75 jupiter
  '';

  services.pcscd.enable = true;

  system.stateVersion = "24.05"; # Don't touch me!
}
