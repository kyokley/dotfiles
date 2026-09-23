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
        '';
      };
    };

    nixos.mars = {
      # Bound SSH connection setup when Mercury is unavailable, including
      # connections made by the Nix daemon for substitution and remote builds.
      programs.ssh.extraConfig = ''
        Host bangup.dyndns.org
            ConnectTimeout 10
      '';

      networking.extraHosts = ''
        ${constants.saturn-ip} saturn # ethernet
        ${constants.saturn-wifi-ip} saturn-wifi # wifi
      '';
    };
  };
}
