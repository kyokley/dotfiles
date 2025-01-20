{ pkgs, lib, ... }:

{
  imports = [
      ../../programs/tailscale.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "mercury"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ollama
  ];

  system.stateVersion = "24.05"; # Don't touch me!

  systemd = {
    services = {
      renew-mattermost-cert = {
        Unit.Description = "Renew Mattermost Cert";
        Service = {
          Type = "oneshot";
          ExecStart = toString (
              pkgs.writeShellScript "renew-mattermost-cert" ''
              PATH=$PATH:${lib.makeBinPath [ pkgs.gnumake pkgs.sudo ]}
              cd /home/yokley/workspace/mattermost && make renew-cert
              ''
              );
        };
      };
    };
    timers = {
      renew-mattermost-cert = {
        Unit = {
            Description = "Renew Mattermost Cert";
            After = [ "network.target" ];
        };
        Timer = {
            OnCalendar = "monthly";
            Persistent = true;
            Unit = "renew-mattermost-cert.service";
        };
        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
