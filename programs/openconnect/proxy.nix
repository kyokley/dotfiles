{
  pkgs,
  lib,
  ...
}: let
  proxy = "http://www-proxy-sjc.oraclecorp.com:80";
  no_proxy = "localhost,127.0.0.0/8,oraclecorp.com,us.oracle.com,*.us.oracle.com,cegbu.docker.oraclecorp.com,odo-docker-local.artifactory.oci.oraclecorp.com,cegbu-textura-docker-virtual.dockerhub-den.oraclecorp.com,cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com,docker-remote.dockerhub-phx.oci.oraclecorp.com,cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.oraclevpn.com,*.oraclevpn.com,.oraclevcn.com,*.oraclevcn.com,docker.io";
  nameservers = [
    "206.223.27.1"
    "206.223.27.2"
    "10.209.76.197"
    "192.135.82.132"
    "8.8.8.8"
  ];
in {
  environment.systemPackages = with pkgs; [
    openconnect
  ];

  environment.variables = {
    HTTP_PROXY = "${proxy}";
    HTTPS_PROXY = "${proxy}";
    http_proxy = "${proxy}";
    https_proxy = "${proxy}";
  };

  networking.proxy = {
    default = "${proxy}";
    noProxy = "${no_proxy}";
  };

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = lib.mkDefault false;
    extraOptions = {
      disable-ipv6 = true;
      no-proxy = true;
      useragent = "AnyConnect Linux_64 4.10.999999";
    };
    protocol = "anyconnect";
    gateway = "myaccess.oraclevpn.com/exc";
    user = "kyokley_us";
    passwordFile = "/var/lib/secrets/openconnect-passwd";
  };

  networking.networkmanager = {
    dns = "systemd-resolved";
    appendNameservers = nameservers;
  };
  services.resolved.fallbackDns = nameservers;

  environment.etc = {
    "/etc/wgetrc" = {
      text = ''
        use_proxy=on
        http_proxy=${proxy}
        https_proxy=${proxy}
      '';
    };
    "/etc/curl/.curlrc" = {
      text = ''
        proxy = ${proxy}
        noproxy = ${no_proxy}
      '';
    };
  };

  virtualisation.docker.daemon.settings = {
    "group" = "docker";
    "hosts" = [
      "fd://"
    ];
    "live-restore" = true;
    "log-driver" = "journald";
    "dns" = nameservers;
  };
}
