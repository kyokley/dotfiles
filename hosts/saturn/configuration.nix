{
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ../../programs/ovpn.nix
    ../../programs/nixos/laptop.nix
    ../../programs/clamav.nix

    # Import SSH
    ./ssh.nix
  ];

  users.users.yokley.openssh.authorizedKeys = {
    keyFiles = [
      ../mars/mars.pub
      ../dioxygen/dioxygen.pub
      ./saturn.pub
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "saturn"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];

  virtualisation.virtualbox.host = {
    package = pkgs-unstable.virtualbox;
    enable = true;
    enableKvm = true;
    enableExtensionPack = true;
    addNetworkInterface = false;
  };
  virtualisation.virtualbox.guest = {
    enable = true;
    dragAndDrop = true;
  };
  users.extraGroups.vboxusers.members = ["yokley"];

  networking.extraHosts = ''
    192.168.50.75 jupiter
  '';

  services.pcscd.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "4096";
    }
  ];

  system.stateVersion = "24.05"; # Don't touch me!
}
