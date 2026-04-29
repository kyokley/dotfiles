{
  flake.modules = {
    homeManager.systemd-services = {
      config,
      lib,
      pkgs,
      ...
    }: {
      systemd.user = {
        startServices = true;
        services = {
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

        timers = {
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
      };
    };
  };
}
