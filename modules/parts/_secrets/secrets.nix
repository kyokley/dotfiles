let
  mercury = builtins.readFile ../../hosts/mercury/mercury.pub;
  mars = builtins.readFile ../../hosts/mars/mars.pub;
  dioxygen = builtins.readFile ../../hosts/dioxygen/dioxygen.pub;
  venus = builtins.readFile ../../hosts/venus/venus.pub;
in {
  "syncthing/mars/key.age" = {
    publicKeys = [mars];
    armor = true;
  };
  "syncthing/mars/cert.age" = {
    publicKeys = [mars];
    armor = true;
  };
  "syncthing/dioxygen/key.age" = {
    publicKeys = [dioxygen];
    armor = true;
  };
  "syncthing/dioxygen/cert.age" = {
    publicKeys = [dioxygen];
    armor = true;
  };
  "syncthing/venus/key.age" = {
    publicKeys = [venus];
    armor = true;
  };
  "syncthing/venus/cert.age" = {
    publicKeys = [venus];
    armor = true;
  };
}
