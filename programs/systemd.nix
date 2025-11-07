{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.systemd-services;
in {
  options.programs.systemd-services = {
    enable = lib.mkEnableOption "systemd-services";
  };

  config = lib.mkMerge [
    (
      lib.mkIf (cfg.enable) {
        systemd.user.startServices = true;
        systemd.user.services = {
          nix-gc = {
            Unit.Description = "Run nix gc";
            Service = {
              Type = "oneshot";
              ExecStart = toString (
                pkgs.writeShellScript "nix-gc-script" ''
                  nix-collect-garbage --delete-older-than 7d
                  ${pkgs.nix}/bin/nix store gc
                ''
              );
            };
          };
        };

        systemd.user.timers = {
          nix-gc = {
            Unit = {
              Description = "Run nix gc";
              After = ["network.target"];
            };
            Timer = {
              OnCalendar = "monthly";
              RandomizedDelaySec = 14400;
              Persistent = true;
              Unit = "nix-gc.service";
            };
            Install.WantedBy = ["timers.target"];
          };
        };
      }
    )
  ];
}
