{
  pkgs,
  username,
  ...
}: {
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
        HandleLidSwitch = "ignore";
        HandlePowerKey = "ignore";
        IdleAction = "suspend";
        IdleActionSec = "1m";
      };
    };
    acpid = {
      enable = true;
      lidEventCommands = ''
        if [ $(DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${username} ${pkgs.xorg.xrandr}/bin/xrandr | grep -P '\d+x\d+\+\d+\+\d+' | wc -l) = "1" ]; then
            lid_state=$(cat /proc/acpi/button/lid/LID0/state | ${pkgs.gawk}/bin/awk '{print $NF}')
            if [ $lid_state = "closed" ]; then
                DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${username} ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork &
                sleep 5
                systemctl suspend
            fi
        fi
      '';
      powerEventCommands = ''
        DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${username} ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork &
      '';
    };
  };
}
