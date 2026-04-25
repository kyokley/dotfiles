{
  inputs,
  config,
  ...
}: {
  flake.modules = {
    nixos = rec {
      common = {
        pkgs,
        lib,
        username,
        hostName,
        inputs,
        ...
      }: {
        nix = {
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
          settings = {
            trusted-users = [
              "root"
              "${username}"
            ];
            download-buffer-size = 524288000;
          };
          buildMachines = [
            {
              hostName = "192.168.50.31";
              sshUser = username;
              systems = ["x86_64-linux"];
              protocol = "ssh";
              maxJobs = 3;
              speedFactor = 2;
              supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
            }
          ];
          distributedBuilds = true;
          extraOptions = ''
            builders-use-substitutes = true
          '';
        };

        # Enable networking
        networking = {
          inherit hostName;
          networkmanager.enable = true;

          # Open ports in the firewall.
          # networking.firewall.allowedTCPPorts = [ ... ];
          # networking.firewall.allowedUDPPorts = [ ... ];
          # Or disable the firewall altogether.
          useDHCP = lib.mkDefault false;
          firewall.enable = lib.mkDefault false;
          firewall.checkReversePath = false;
          useNetworkd = true;
        };

        systemd = {
          services.NetworkManager-wait-online.enable = true;
          network.wait-online.enable = false;
        };

        boot = {
          initrd.systemd.network.wait-online.enable = false;
          tmp.cleanOnBoot = true;
        };

        # Set your time zone.
        # time.timeZone = lib.mkDefault "America/Chicago";

        services = {
          localtimed.enable = true;
          geoclue2.enable = true;

          # Enable the XFCE Desktop Environment.
          xserver = {
            enable = true;
            xkb.layout = "us";
            xkb.variant = "";

            displayManager.lightdm = {
              enable = true;
            };
            windowManager.qtile = {
              enable = true;
              extraPackages = python3Packages:
                with python3Packages; [
                  requests
                  pillow
                  pywal
                  python-dateutil
                ];
            };
          };
          displayManager.defaultSession = lib.mkDefault "qtile";

          # Enable CUPS to print documents.
          printing.enable = true;

          # Enable sound with pipewire.
          pulseaudio.enable = false;

          blueman.enable = true;
          pipewire = {
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

          flatpak.enable = true;

          earlyoom.enable = true;
          resolved.enable = true;
          fwupd.enable = true;
        };

        # Select internationalisation properties.
        i18n = {
          defaultLocale = "en_US.UTF-8";

          extraLocaleSettings = {
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
        };

        # Enable bluetooth
        hardware = {
          bluetooth.enable = true;
          bluetooth.powerOnBoot = true;
        };

        security.rtkit.enable = true;

        # Enable touchpad support (enabled default in most desktopManager).
        # services.xserver.libinput.enable = true;

        # Enable flatpaks
        xdg = {
          portal = {
            enable = true;
            extraPortals = [pkgs.xdg-desktop-portal-gtk];
            config.common.default = "*";
          };
        };

        # Enable docker
        virtualisation.docker = {
          enable = true;
        };

        fonts = {
          fontDir.enable = true;
          enableGhostscriptFonts = true;
          packages = with pkgs; [
            # nerd-fonts.corefonts
            nerd-fonts.dejavu-sans-mono
            nerd-fonts.inconsolata
            # liberation_ttf
            # terminus_font
            # ttf_bitstream_vera
            # vistafonts
          ];
        };

        # Define a user account. Don't forget to set a password with ‘passwd’.
        users.users.${username} = {
          shell = pkgs.zsh;
          isNormalUser = true;
          description = "Kevin Yokley";
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
            "vboxusers"
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
          brave
          terminator
          pavucontrol
          volctl
          htop
          git
          docker
          rofi
          xclip
          feh
          alsa-utils
          slack
          zoom-us
          pulsemixer
        ];

        systemd.tmpfiles.rules = ["d /tmp 1777 root root 7d"];

        programs = {
          neovim = {
            enable = false;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
          };

          # Needed to make screen locker work
          i3lock.enable = true;
          zsh.enable = true;
        };

        environment.variables = {
          EDITOR = "nvim";
        };

        # List services that you want to enable:

        # Enable the OpenSSH daemon.
        # services.openssh.enable = true;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          # users.${username} = import ../../../home-manager/home.nix;
        };

        fileSystems."/" = {
          fsType = "bcachefs";
          options = ["casefold_disabled"];
        };
      };
    };

    homeManager = rec {
      nixos = {
        inputs,
        pkgs,
        lib,
        username,
        ...
      }: let
        homeDir = "/home/${username}";
        reboot-kexec = pkgs.writeScriptBin "reboot-kexec" ''
          #!${pkgs.stdenv.shell}
          cmdline="init=$(readlink -f /nix/var/nix/profiles/system/init) $(cat /nix/var/nix/profiles/system/kernel-params)"
          sudo kexec -l /nix/var/nix/profiles/system/kernel --initrd=/nix/var/nix/profiles/system/initrd --append="$cmdline"
          sudo systemctl kexec
        '';
        toggle-picom = pkgs.writeScriptBin "toggle-picom" ''
          #!${pkgs.stdenv.shell}
          if systemctl --user status picom | grep 'running'; then
            systemctl --user stop picom
          else
            systemctl --user start picom
          fi
        '';
        open-all = pkgs.writeScriptBin "open" ''
          for file in $@
          do
            xdg-open "$file"
          done
        '';
      in {
        imports = [
          inputs.self.modules.homeManager.terminator
          inputs.self.modules.homeManager.dunst
          inputs.self.modules.homeManager.rofi
          inputs.self.modules.homeManager.qtile
          inputs.self.modules.homeManager.kitty
        ];

        home.packages = [
          pkgs.arandr
          pkgs.dunst
          pkgs.libreoffice
          pkgs.nitrogen
          pkgs.python312Packages.bpython
          pkgs.thunderbird
          pkgs.nerd-fonts.hack
          pkgs.vlc
          reboot-kexec
          toggle-picom
          open-all
        ];

        home.file = {
          ".config/qtile" = {
            source = ./qtile;
            target = ".config/qtile";
            recursive = true;
          };
          ".config/picom/picom-custom.conf" = {
            source = ./picom.conf;
          };
          ".config/nixpkgs/config.nix" = {
            text = "{ allowUnfree = true; }";
          };
        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "application/pdf" = ["brave-browser.desktop"];
            "text/html" = ["brave-browser.desktop"];
            "x-scheme-handler/http" = ["brave-browser.desktop"];
            "x-scheme-handler/https" = ["brave-browser.desktop"];
          };
        };

        home.shellAliases = {
          nixos-switch = "nixos-rebuild switch --refresh --sudo --flake 'github:kyokley/dotfiles'";
          nixos-test = "nixos-rebuild test --refresh --sudo --flake 'github:kyokley/dotfiles'";
        };

        services.blueman-applet.enable = true;

        services.xidlehook = {
          enable = true;
          detect-sleep = true;
          not-when-fullscreen = true;
          timers = [
            {
              delay = 590;
              command = "${pkgs.dunst}/bin/dunstify 'Locking screen in 10 secs' -t 10";
            }
            {
              delay = 20; # Add an extra 10 secs to allow waking up after screen blank
              command = "${pkgs.betterlockscreen}/bin/betterlockscreen --lock";
            }
          ];
        };

        services.network-manager-applet.enable = true;
        systemd.user.targets.tray = {
          Unit = {
            Description = "Home Manager System Tray";
            Requires = ["graphical-session-pre.target"];
          };
        };

        systemd.user.services = {
          update-lockscreen = {
            Unit.Description = "Update lockscreen background image";
            Service = {
              Type = "oneshot";
              ExecStart = toString (
                pkgs.writeShellScript "betterlockscreen-update-script" ''
                  PATH=$PATH:${lib.makeBinPath [pkgs.nix pkgs.coreutils pkgs.busybox pkgs.xrdb]}
                  ${pkgs.betterlockscreen}/bin/betterlockscreen -u ${homeDir}/Pictures/wallpapers --fx ""
                ''
              );
            };
          };
        };

        systemd.user.timers = {
          update-lockscreen = {
            Unit = {
              Description = "Update betterlockscreen";
              After = ["network.target"];
            };
            Timer = {
              OnCalendar = "*-*-* *:0/5:00";
              Persistent = true;
              Unit = "update-lockscreen.service";
            };
            Install.WantedBy = ["timers.target"];
          };
        };

        services = {
          picom = {
            enable = true;
            extraArgs = ["--config=${homeDir}/.config/picom/picom-custom.conf"];
          };
        };
      };
    };
  };
}
