{ pkgs, ... }:
{
    services = {
        logind = {
            lidSwitch = "ignore";
            extraConfig = ''
                HandlePowerKey=ignore
                HandleLidSwitch=ignore
            '';
        };
        acpid = {
            enable = true;
            lidEventCommands =
            ''
                if [ $(DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${builtins.getEnv "USER"} ${pkgs.xorg.xrandr}/bin/xrandr | grep -P '\d+x\d+\+\d+\+\d+' | wc -l) = "1" ]; then
                    lid_state=$(cat /proc/acpi/button/lid/LID0/state | ${pkgs.gawk}/bin/awk '{print $NF}')
                    if [ $lid_state = "closed" ]; then
                        systemctl suspend
                        DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${builtins.getEnv "USER"} ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork
                    fi
                fi
            '';
            powerEventCommands =
            ''
                systemctl suspend
                DISPLAY=:0 ${pkgs.sudo}/bin/sudo -u ${builtins.getEnv "USER"} ${pkgs.betterlockscreen}/bin/betterlockscreen --lock -- --nofork
            '';
        };
    };
}
