{
  flake.modules.homeManager = let
    reboot-kexec-attrs = {
      name = "reboot-kexec";
      text = ''
        cmdline="init=$(readlink -f /nix/var/nix/profiles/system/init) $(cat /nix/var/nix/profiles/system/kernel-params)"
        sudo kexec -l /nix/var/nix/profiles/system/kernel --initrd=/nix/var/nix/profiles/system/initrd --append="$cmdline"
        sudo systemctl kexec
      '';
    };
  in {
    nixos = {pkgs, ...}: let
      reboot-kexec = pkgs.writeShellApplication reboot-kexec-attrs;
    in {
      home = {
        packages = [
          reboot-kexec
        ];
      };
    };

    noctalia = {pkgs, ...}: let
      reboot-kexec = pkgs.writeShellApplication reboot-kexec-attrs;
    in {
      programs.noctalia = {
        settings.shell = {
          session = {
            grid = true;
            grid_columns = 2;
            actions = [
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
                command = "${reboot-kexec}/bin/reboot-kexec";
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
          };
        };
      };
    };
  };
}
