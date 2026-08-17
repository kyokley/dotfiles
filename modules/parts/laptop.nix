{
  flake.modules.nixos = {
    laptop = {pkgs, ...}: {
      services = {
        auto-cpufreq = {
          enable = true;
          settings = {
            battery = {
              governor = "powersave";
              turbo = "never";
            };
            charger = {
              governor = "performance";
              turbo = "auto";
            };
          };
        };
        logind = {
          settings.Login = {
            HandleLidSwitch = "suspend";
            HandleLidSwitchExternalPower = "ignore";
            HandlePowerKey = "ignore";
            IdleAction = "suspend";
            IdleActionSec = "10m";
          };
        };
      };
      systemd.services.logind-ac-idle-inhibitor = {
        description = "Inhibit logind idle suspend while on AC power";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "logind-ac-idle-inhibitor" ''
            ac_online() {
              for supply in /sys/class/power_supply/*; do
                if [ -r "$supply/type" ] && [ "$(cat "$supply/type")" = "Mains" ] \
                  && [ -r "$supply/online" ] && [ "$(cat "$supply/online")" = "1" ]; then
                  return 0
                fi
              done
              return 1
            }

            if [ "$1" = "--inhibit-watcher" ]; then
              while ac_online; do
                ${pkgs.coreutils}/bin/sleep 5
              done
              exit 0
            fi

            while :; do
              if ac_online; then
                ${pkgs.systemd}/bin/systemd-inhibit --what=sleep --mode=block \
                  --who=logind-ac-idle-inhibitor \
                  --why="AC power is connected" \
                  "$0" --inhibit-watcher
              else
                ${pkgs.coreutils}/bin/sleep 5
              fi
            done
          '';
          Restart = "always";
        };
      };
    };

    qtile = {
      pkgs,
      username,
      ...
    }: {
      services = {
        acpid = {
          enable = true;
          lidEventCommands = ''
            if [ $(DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${username} ${pkgs.xrandr}/bin/xrandr | grep -P '\d+x\d+\+\d+\+\d+' | wc -l) = "1" ]; then
                lid_state=$(cat /proc/acpi/button/lid/LID0/state | ${pkgs.gawk}/bin/awk '{print $NF}')
                if [ $lid_state = "closed" ]; then
                    DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${username} ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork &
                    sleep 5
                    ac_online=false
                    for supply in /sys/class/power_supply/*; do
                        if [ -r "$supply/type" ] && [ "$(cat "$supply/type")" = "Mains" ] \
                          && [ -r "$supply/online" ] && [ "$(cat "$supply/online")" = "1" ]; then
                            ac_online=true
                            break
                        fi
                    done
                    if [ "$ac_online" = false ]; then
                        systemctl suspend
                    fi
                fi
            fi
          '';
          powerEventCommands = ''
            DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${username} ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork &
          '';
        };
      };
    };
  };
}
