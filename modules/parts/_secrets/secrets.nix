let
  identities = {
    dioxygen = builtins.readFile ../../hosts/dioxygen/dioxygen.pub;
    jupiter = builtins.readFile ../../hosts/jupiter/jupiter.pub;
    mars = builtins.readFile ../../hosts/mars/mars.pub;
    mercury = builtins.readFile ../../hosts/mercury/mercury.pub;
    venus = builtins.readFile ../../hosts/venus/venus.pub;
  };

  syncthing-hosts = [
    "dioxygen"
    "jupiter"
    "mars"
    "mercury"
    "venus"
  ];

  # This is a bit of a hack to avoid having to repeat the same code for each host. We can generate the attrs for each host and then merge them together.
  # "syncthing/${host}/key.age" = {
  #   publicKeys = [${host}];
  #   armor = true;
  # };
  # "syncthing/${host}/cert.age" = {
  #   publicKeys = [${host}];
  #   armor = true;
  # };
  syncthing-vars = ["certs" "keys"];
  syncthing-attrs = builtins.listToAttrs (map (var: {
      name = "syncthing-${var}";
      value = builtins.listToAttrs (map (host: {
          name = "syncthing/${host}/${builtins.substring 0 ((builtins.stringLength var) - 1) var}.age";
          value = {
            publicKeys = [identities.${host}];
            armor = true;
          };
        })
        syncthing-hosts);
    })
    syncthing-vars);
in
  syncthing-attrs.syncthing-certs
  // syncthing-attrs.syncthing-keys
  // {
  }
