{
  flake.modules = let
    mkMachine = sshUser: hostName: {
      inherit hostName sshUser;
      systems = ["x86_64-linux"];
      protocol = "ssh";
      maxJobs = 3;
      speedFactor = 2;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    };

    ssh_conf = ''
      Host bangup.dyndns.org
          HostName bangup.dyndns.org
          Port 10101
          StrictHostKeyChecking=accept-new
    '';

    # Daemon-level settings — only applies in NixOS context where user is trusted
    nixos_distributed_build_conf = {username, ...}: {
      nix = {
        buildMachines = [
          (mkMachine username "bangup.dyndns.org")
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };

      programs.ssh = {
        extraConfig = ssh_conf;
      };
    };

    # User-level settings only — daemon settings like buildMachines, builders-use-substitutes
    # require trusted-user status and can't be set via home-manager on non-NixOS systems
    hm_distributed_build_conf = {username, ...}: {
      programs.ssh = {
        enable = true;
        extraConfig = ssh_conf;
        enableDefaultConfig = false;
        settings."*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
      };
    };
  in {
    nixos.distributedBuilds = nixos_distributed_build_conf;
    homeManager.distributedBuilds = hm_distributed_build_conf;
  };
}
