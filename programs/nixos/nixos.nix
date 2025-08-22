{
  pkgs,
  lib,
  ...
}: let
  homeDir = "/home/yokley";
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
    ../../programs/terminator.nix
    ../../programs/dunst/dunst.nix
    ../../programs/rofi/rofi.nix
    ../../programs/qtile/qtile.nix
    ../../programs/kitty.nix
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
      source = ../qtile;
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
    nixos-switch = "nixos-rebuild switch --refresh --use-remote-sudo --flake 'git+ssh://git@venus.ftpaccess.cc:10022/kyokley/dotfiles.git?ref=main'";
    nixos-test = "nixos-rebuild test --refresh --use-remote-sudo --flake 'git+ssh://git@venus.ftpaccess.cc:10022/kyokley/dotfiles.git?ref=main'";
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
            PATH=$PATH:${lib.makeBinPath [pkgs.nix pkgs.coreutils pkgs.busybox pkgs.xorg.xrdb]}
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
}
