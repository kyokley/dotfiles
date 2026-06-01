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
              "tcp://192.168.50.145"
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
          jupiter = {
            id = "OB2E2QP-APZJDAT-W6C36QY-GXCZHOB-U7GCWPJ-WGMMGAD-4U4NHEG-ZXJULAK";
            addresses = [
              "tcp://jupiter"
            ];
          };
          mercury = {
            id = "YW2X2OD-S3GVEJH-FNHBFOF-F6KTG7Y-4OZPRHV-B3AM625-LQMRATN-BTR53AF";
            addresses = [
              "tcp://mercury"
              "tcp://192.168.50.31"
            ];
          };
          saturn = {
            id = "2QQKAGF-26OP2ZE-NAIE3X4-GEWXWC2-RKHG25Z-FKKKZBU-K6S2OZZ-2DEB5A4";
            addresses = [
              "tcp://saturn"
              "tcp://192.168.50.126"
              "tcp://192.168.50.96"
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
          "wallpapers" = {
            id = "wallpapers";
            devices = [
              "mars"
              "mercury"
              "saturn"
            ];
            path = "${config.home.homeDirectory}/Pictures/wallpapers";
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
