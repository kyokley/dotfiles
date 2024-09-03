{pkgs, lib, ...}:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  services.home-manager.autoUpgrade = {
    enable = false;
    frequency = "weekly";
  };

  systemd.user.services = {
      home-manager-auto-upgrade = {
        Unit.Description = "Home Manager upgrade";

        Service.ExecStart = toString
          (pkgs.writeShellScript "home-manager-auto-upgrade" ''
           PATH=$PATH:${lib.makeBinPath [ pkgs.nix pkgs.coreutils pkgs.busybox ]}

           echo "Update Nix's channels"
           ${pkgs.nix}/bin/nix-channel --update
           echo "Upgrade Home Manager"
           ${pkgs.home-manager}/bin/home-manager switch
           ${pkgs.home-manager}/bin/home-manager expire-generations "-30 days"
           ${pkgs.home-manager}/bin/home-manager switch --flake 'github:kyokley/dotfiles#mercury'

           ${pkgs.nix}/bin/nix-store --gc
           '');
      };
  };

  systemd.user.timers = {
      home-manager-auto-upgrade = {
          Unit = {
              Description = "Run home-manager autoupgrade script";
              After = [ "network.target" ];
          };
          Timer = {
              OnCalendar = "weekly";
              Persistent = true;
              Unit = "home-manager-auto-upgrade.service";
          };
          Install.WantedBy = ["timers.target"];
      };
  };

}
