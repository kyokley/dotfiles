{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
          experimental-features = nix-command flakes
          '';
      gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
      };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages = python312Packages: with python312Packages; [
        requests
        schedule
        pillow
        pywal
      ];
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable flatpaks
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";
  services.flatpak.enable = true;

  # Enable tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  services.earlyoom.enable = true;

  # Enable docker
  virtualisation.docker = {
    enable = true;
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
       corefonts
       dejavu_fonts
       inconsolata
       # liberation_ttf
       # terminus_font
       # ttf_bitstream_vera
       # vistafonts
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yokley = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Kevin Yokley";
    extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
    ];
    packages = with pkgs; [
      firefox
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    wget
    curl
    terminator
    tailscale
    pavucontrol
    volctl
    htop
    git
    docker
    rofi
    xclip
    feh
    python312Packages.qtile
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.neovim = {
      enable = false;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
  };

  environment.variables.EDITOR = "nvim";
  programs.zsh.enable = true;


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
