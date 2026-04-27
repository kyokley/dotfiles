{
  flake.modules = {
    nixos.distributedBuilds = {username, ...}: {
      nix = {
        buildMachines = [
          {
            hostName = "192.168.50.31";
            sshUser = username;
            systems = ["x86_64-linux"];
            protocol = "ssh";
            maxJobs = 3;
            speedFactor = 2;
            supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
          }
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
          {
            hostName = "192.168.50.31";
            sshUser = username;
            systems = ["x86_64-linux"];
            protocol = "ssh";
            maxJobs = 3;
            speedFactor = 2;
            supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
          }
        ];
        distributedBuilds = true;
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };
    };
  };
}
