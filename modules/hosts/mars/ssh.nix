{
  flake.modules = {
    homeManager."yokley@mars" = {
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host saturn
              Port 10101
          Host saturn-wifi
              Port 10101
          Host saturn-eth
              Port 10101
        '';
      };
    };

    nixos.mars = {
      networking.extraHosts = ''
        192.168.50.126 saturn # ethernet
        192.168.50.96 saturn-wifi # wifi
      '';
    };
  };
}
