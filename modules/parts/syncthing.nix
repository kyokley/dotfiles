{
  flake.modules.homeManager.syncthing = {
    pkgs,
    config,
    hostName,
    ...
  }: {
    services.syncthing = {
      enable = true;
      settings = {
        devices = {
          mars = {
            id = "LLSD6II-ROUHKRL-3XBQA7D-G7QEUWD-W6RNLN2-NL7SP5S-WUVTCDN-4XSVGQK";
            addresses = [
              "tcp://mars"
            ];
          };
          dioxygen = {
            id = "HVFOU6H-GRPJWVP-B4DSXRS-O2XMHRC-73TDGHP-IJKNALJ-BLN5TVA-YZJDUA3";
            addresses = [
              "tcp://dioxygen"
            ];
          };
          venus = {
            id = "E2M66D3-ZQZNVV4-JJZ7PMZ-UTIGMG5-QUEPYO5-HPVG4Q5-WV5RB2Y-ZFNQCAL";
            addresses = [
              "tcp://venus"
            ];
          };
        };
        folders = {
          "taxes" = {
            id = "taxes";
            devices = [
              "mars"
              "dioxygen"
              "venus"
            ];
            path = "${config.home.homeDirectory}/Documents/taxes";
            type = "sendreceive";
          };
        };
      };
    };

    age.secrets = {
      "${hostName}-syncthing-key".file = ../parts/_secrets/syncthing/${hostName}/key.age;
      "${hostName}-syncthing-cert".file = ../parts/_secrets/syncthing/${hostName}/cert.age;
    };
    services.syncthing = {
      cert = ''${config.age.secrets."${hostName}-syncthing-cert".path}'';
      key = ''${config.age.secrets."${hostName}-syncthing-key".path}'';
    };

    systemd.user.services.syncthing.Unit = {
      After = ["agenix.service"];
      Wants = ["agenix.service"];
    };
  };
}
