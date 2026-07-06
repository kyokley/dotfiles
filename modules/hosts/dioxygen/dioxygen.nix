{
  flake.modules = {
    homeManager."yokley@dioxygen" = {
      inputs,
      ...
    }: {
      imports = with inputs.self.modules.homeManager; [
        dev
        distributedBuilds
        opencode
        syncthing
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
            HostName 192.168.50.126
            Port 10101
          Host saturn-wifi
            HostName 192.168.50.96
            Port 10101
        '';
      };
    };

    darwin.dioxygen = {
      system.stateVersion = 7;
    };
  };
}
