{
  flake.modules = {
    homeManager = let
      reboot-kexec = pkgs:
        pkgs.writeShellApplication {
          name = "reboot-kexec";
          text = ''
            cmdline="init=$(readlink -f /nix/var/nix/profiles/system/init) $(cat /nix/var/nix/profiles/system/kernel-params)"
            sudo kexec -l /nix/var/nix/profiles/system/kernel --initrd=/nix/var/nix/profiles/system/initrd --append="$cmdline"
            sudo systemctl kexec
          '';
        };

      noctalia_shutdown_actions = pkgs: [
        {
          action = "shutdown";
          countdown_seconds = 10;
          variant = "destructive";
          shortcut = "1";
        }
        {
          action = "reboot";
          countdown_seconds = 10;
          shortcut = "2";
        }
        {
          action = "lock";
          variant = "secondary";
          shortcut = "3";
        }
        {
          action = "logout";
          countdown_seconds = 10;
          shortcut = "4";
        }
      ];
      noctalia_shutdown_actions_with_kexec = pkgs: [
        {
          action = "shutdown";
          countdown_seconds = 10;
          variant = "destructive";
          shortcut = "1";
        }
        {
          action = "reboot";
          countdown_seconds = 10;
          shortcut = "2";
          command = "${reboot-kexec pkgs}/bin/reboot-kexec";
        }
        {
          action = "lock";
          variant = "secondary";
          shortcut = "3";
        }
        {
          action = "logout";
          countdown_seconds = 10;
          shortcut = "4";
        }
      ];
    in {
      nixos = {pkgs, ...}: {
        home = {
          packages = [
            (reboot-kexec pkgs)
          ];
        };
      };

      noctalia = {pkgs, ...}: {
        programs.noctalia = {
          settings.shell = {
            session = {
              grid = true;
              grid_columns = 2;
              actions = noctalia_shutdown_actions pkgs;
            };
          };
        };
      };

      saturn = {
        pkgs,
        lib,
        ...
      }: {
        programs.noctalia.settings.shell.session.actions = lib.mkForce (noctalia_shutdown_actions_with_kexec pkgs);
      };
    };

    # The noctalia session panel runs custom action commands fully detached
    # (no tty, stdio → /dev/null), so `sudo` inside reboot-kexec can't prompt
    # for a password and the script aborts. Grant NOPASSWD for exactly the two
    # privileged commands it runs — nothing more.
    nixos.common = {username, ...}: {
      security.sudo.extraRules = [
        {
          users = [username];
          commands = [
            {
              command = "/run/current-system/sw/bin/kexec";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/systemctl kexec";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
