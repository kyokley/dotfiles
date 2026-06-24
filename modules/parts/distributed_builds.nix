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

    distributed_build_conf = {username, ...}: {
      nix = {
        buildMachines = [
          (mkMachine username "bangup.dyndns.org")
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };

      programs.ssh.extraConfig = ssh_conf;
    };
  in {
    nixos.distributedBuilds = distributed_build_conf;
    homeManager.distributedBuilds = distributed_build_conf;
  };
}
