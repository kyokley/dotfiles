{config, lib, pkgs, ...}:
let
    cfg = config.programs.systemd-services;
in
{
    options.programs.systemd-services = {
        enable = lib.mkEnableOption "systemd-services";

        environment = lib.mkOption {
            default = "default";
            type = lib.types.str;
            description = ''
                Environment to use for home-manager configuration.
            '';
        };
    };

    config = {
        systemd.user.startServices = true;
        systemd.user.services = {
            home-manager-update = {
                Unit.Description = "Update home-manager config";
                Service = {
                    Type = "oneshot";
                    ExecStart = toString (
                        pkgs.writeShellScript "home-manager-update-script" ''
                        PATH=$PATH:${lib.makeBinPath [ pkgs.nix pkgs.coreutils ]}
                        ${pkgs.home-manager}/bin/home-manager switch --flake 'github:kyokley/dotfiles#${cfg.environment}'
                    ''
                    );
                };
            };
            home-manager-expire = {
                Unit.Description = "Expire home-manager generation";
                Service = {
                    Type = "oneshot";
                    ExecStart = toString (
                        pkgs.writeShellScript "home-manager-expire-script" ''
                        PATH=$PATH:${lib.makeBinPath [ pkgs.nix ]}
                        test $(echo "$(${pkgs.home-manager}/bin/home-manager generations | wc -l) > 1" | bc) -eq 1 && ${pkgs.home-manager}/bin/home-manager expire-generations "-30 days"
                    ''
                    );
                };
            };
            nix-gc = {
                Unit.Description = "Run nix gc";
                Service = {
                    Type = "oneshot";
                    ExecStart = toString (
                        pkgs.writeShellScript "nix-gc-script" ''
                        ${pkgs.nix}/bin/nix store gc
                    ''
                    );
                };
            };
        };

        systemd.user.timers = {
            home-manager-update = {
                Unit = {
                    Description = "Update home-manager";
                    After = [ "network.target" ];
                };
                Timer = {
                    OnCalendar = "daily";
                    Persistent = true;
                };
            };
            home-manager-expire = {
                Unit = {
                    Description = "Expire home-manager generations";
                    After = [ "network.target" ];
                };
                Timer = {
                    OnCalendar = "daily";
                    Persistent = true;
                };
            };
            nix-gc = {
                Unit = {
                    Description = "Run nix gc";
                    After = [ "network.target" ];
                };
                Timer = {
                    OnCalendar = "monthly";
                    Persistent = true;
                };
            };
        };

    };
}
