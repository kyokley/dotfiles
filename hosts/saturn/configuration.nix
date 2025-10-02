{
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ../../programs/ovpn.nix
    ../../misc/laptop.nix
    ../../programs/clamav.nix
    ../../misc/login.nix

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
  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 80;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    ipu6-drivers = super.ipu6-drivers.overrideAttrs (
      final: previous: rec {
        src = builtins.fetchGit {
          url = "https://github.com/intel/ipu6-drivers.git";
          ref = "master";
          rev = "b4ba63df5922150ec14ef7f202b3589896e0301a";
        };
        patches = [
          "${src}/patches/0001-v6.10-IPU6-headers-used-by-PSYS.patch"
        ];
      }
    );
  });

  networking.hostName = "saturn"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];

  virtualisation.virtualbox.host = {
    package = pkgs.virtualbox;
    enable = true;
    enableKvm = true;
    enableExtensionPack = true;
    addNetworkInterface = false;
  };
  virtualisation.virtualbox.guest = {
    # Try re-enabling this at some point to see if it build successfully
    enable = false;
    dragAndDrop = true;
  };

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
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

  programs.nix-ld.enable = true;
}
