{
  flake.modules.homeManager.syncthing = {pkgs, ...}: {
    services.syncthing = {
      enable = true;
      extraFlags = ["--no-default-folder"];
      settings = {
        devices = {
          mars = {
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
