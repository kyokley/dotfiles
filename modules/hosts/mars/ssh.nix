{constants, ...}: {
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
        ${constants.saturn-ip} saturn # ethernet
        ${constants.saturn-wifi-ip} saturn-wifi # wifi
      '';
    };
  };
}
