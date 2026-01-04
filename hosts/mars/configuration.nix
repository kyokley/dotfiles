{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/nixos/programs/tailscale.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/login.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  networking.hostName = "mars"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    protonvpn-gui
  ];

  system.stateVersion = "24.05"; # Don't touch me!

  virtualisation.docker.daemon.settings = {
    "group" = "docker";
    "hosts" = [
      "fd://"
    ];
    "live-restore" = true;
    "log-driver" = "journald";
    "dns" = [
      "8.8.8.8"
    ];
  };

  networking.extraHosts = ''
    192.168.50.126 saturn # ethernet
    192.168.50.96 saturn-wifi # wifi
  '';

  services.xserver.videoDrivers = ["amdgpu"];

  services.oracle-database-container = let
    initScriptFile = builtins.toFile "01_create.sql" ''
      ALTER SESSION SET CONTAINER=FREEPDB1;
      CREATE USER TEST IDENTIFIED BY test QUOTA UNLIMITED ON USERS;
      GRANT CONNECT, RESOURCE TO TEST;

      CREATE TABLE student (
          last_name       VARCHAR2(15) NOT NULL,
          first_name      VARCHAR2(15) NOT NULL,
          id              NUMBER(6) PRIMARY KEY
      );
      INSERT INTO students (last_name, first_name, id)
      VALUES ('Doe', 'John', 1001);

    '';
  in {
    enable = true;
    openFirewall = true;
    passwordFile = toString (builtins.toFile "passwordFile" ''
      password
    '');
    initScript = initScriptFile;
  };

  virtualisation = {
    diskSize = lib.mkForce 100000;
  };
}
