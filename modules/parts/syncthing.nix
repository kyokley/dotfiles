{
  flake.modules.homeManager.syncthing = {pkgs, ...}: {
    services.syncthing = {
      enable = true;
      extraFlags = ["--no-default-folder"];
      settings = {
        devices = {
          mars = {
            id = "LLSD6II-ROUHKRL-3XBQA7D-G7QEUWD-W6RNLN2-NL7SP5S-WUVTCDN-4XSVGQK";
            addresses = [
              "tcp://mars"
            ];
          };
        };
        folders = {
          "sen_docs" = {
            id = "sen_docs";
            devices = [
              "mars"
              "mercury"
              "jupiter"
              "venus"
            ];
            path = "/home/sen/docs";
            type = "sendreceive";
          };
        };
      };
    };
  };
}
