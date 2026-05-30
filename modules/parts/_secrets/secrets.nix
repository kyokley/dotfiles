let
  mercury = builtins.readFile ../../hosts/mercury/mercury.pub;
  mars = builtins.readFile ../../hosts/mars/mars.pub;
  dioxygen = builtins.readFile ../../hosts/dioxygen/dioxygen.pub;
  venus = builtins.readFile ../../hosts/venus/venus.pub;
  jupiter = builtins.readFile ../../hosts/jupiter/jupiter.pub;

  syncthing-hosts = [
    mars
    dioxygen
    venus
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
          name = "syncthing/${host}/cert.age";
          value = {
            publicKeys = [host];
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
