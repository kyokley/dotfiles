{
  imports =
    [ # Include the results of the hardware scan.
      /home/yokley/.config/nixos/common-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-b52b05e2-4809-4fce-8bb9-a127722145c3".device = "/dev/disk/by-uuid/b52b05e2-4809-4fce-8bb9-a127722145c3";
  networking.hostName = "mars"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  system.stateVersion = "23.11"; # Did you read the comment?

}
