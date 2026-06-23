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
  in {
    nixos.distributedBuilds = {username, ...}: {
      nix = {
        buildMachines = [
          # (mkMachine username "192.168.50.31")
          (mkMachine username "mercury.taila5201.ts.net")
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };
    };

    homeManager.distributedBuilds = {username, ...}: {
      nix = {
        buildMachines = [
          # (mkMachine username "192.168.50.31")
          (mkMachine username "mercury.taila5201.ts.net")
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };
    };
  };
}
