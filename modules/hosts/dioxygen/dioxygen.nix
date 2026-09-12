{
  flake.modules = {
    homeManager."yokley@dioxygen" = {inputs, constants, ...}: {
      imports = with inputs.self.modules.homeManager; [
        dev
        distributedBuilds
        opencode
        syncthing
        obsidian
      ];

      home = {
        stateVersion = "24.05";
      };

      programs = {
        git.settings.alias = {
          select = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | choose | xargs -r git switch'';
        };

        ssh.extraConfig = ''
          Host saturn
            HostName ${constants.saturn-ip}
            Port 10101
          Host saturn-wifi
            HostName ${constants.saturn-wifi-ip}
            Port 10101
        '';
      };
    };

    darwin.dioxygen = {
      system.stateVersion = 7;
      networking.hostName = "dioxygen";
    };
  };
}
