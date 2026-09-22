{constants, ...}: {
  flake.modules = {
    homeManager."yokley@dioxygen" = {inputs, ...}: {
      imports = with inputs.self.modules.homeManager; [
        dev
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

        ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "Host saturn" = {
              HostName = constants.saturn-ip;
              Port = 10101;
            };
            "Host saturn-wifi" = {
              HostName = constants.saturn-wifi-ip;
              Port = 10101;
            };
          };
        };
      };

      nix.settings = {
        substituters = [
          "https://horus.cachix.org"
        ];
        trusted-public-keys = [
          "horus.cachix.org-1:YZ4tQYAoKH+zkKbD4aqFcMHgZxIM7Uo4dPEfwUrubT4="
        ];
      };
    };

    darwin.dioxygen = {
      system.stateVersion = 7;
      networking.hostName = "dioxygen";

      nix.settings = {
        substituters = [
          "https://horus.cachix.org"
        ];
        trusted-public-keys = [
          "horus.cachix.org-1:YZ4tQYAoKH+zkKbD4aqFcMHgZxIM7Uo4dPEfwUrubT4="
        ];
      };
    };
  };
}
