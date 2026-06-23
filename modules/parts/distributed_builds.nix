{
  flake.modules = let
    mkMachine = username: hostName: {
      inherit hostName;
      sshUser = username;
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
  in {
    nixos.distributedBuilds = {username, ...}: {
      nix = {
        buildMachines = [
          # (mkMachine username "192.168.50.31")
          (mkMachine username "bangup.dyndns.org")
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };

      programs.ssh.extraConfig = ssh_conf;
    };

    homeManager.distributedBuilds = {username, ...}: {
      nix = {
        buildMachines = [
          # (mkMachine username "192.168.50.31")
          (mkMachine username "bangup.dyndns.org")
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };

      programs.ssh.extraConfig = ssh_conf;
    };
  };
}
