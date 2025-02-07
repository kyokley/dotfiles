{
  pkgs,
  lib,
  ...
}: let
  # domains = lib.concatStringsSep " " [
  #   "apex.oraclecorp.com"
  #   "artifacthub-phx.oci.oraclecorp.com"
  #   "artifactory.oci.oraclecorp.com"
  #   "badge.oraclecorp.com"
  #   "cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com"
  #   "cegbu-textura-docker-virtual.dockerhub-den.oraclecorp.com"
  #   "cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com"
  #   "cegbu.docker.oraclecorp.com"
  #   "cegbu.oraclecorp.com"
  #   "cloudlab.us.oracle.com"
  #   "confluence.oraclecorp.com"
  #   "docker-remote.dockerhub-phx.oci.oraclecorp.com"
  #   "exchange.oraclecorp.com"
  #   "gbuconfluence.oraclecorp.com"
  #   "gbujira.oraclecorp.com"
  #   "global-ebusiness.oraclecorp.com"
  #   "gps.oracle.com"
  #   "hrservices.oraclecorp.com"
  #   "mydesktop.oraclecorp.com"
  #   "oci-ssp.oracle-ocna.com"
  #   "ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com"
  #   "ocitpmpypi.us.oracle.com"
  #   "ocp.oraclecorp.com"
  #   "odo-docker-local.artifactory.oci.oraclecorp.com"
  #   "oim.oraclecorp.com"
  #   "permissions.oci.oraclecorp.com"
  #   "phx-c-csec-awp-01.us5.oraclecloud.com"
  #   "phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com"
  #   "pls.appoci.oraclecorp.com"
  #   "printers.oraclecorp.com"
  #   "testrail.us.oracle.com"
  #   "u2f-validator.idp.mc1.oracleiaas.com"
  #   "utilus.us.oracle.com"
  #   "www-proxy-adcq7-new.us.oracle.com"
  #   "www-proxy-adcq7.us.oracle.com"
  #   "www-proxy-ash7.us.oracle.com"
  #   "www-proxy-hqdc.us.oracle.com"
  #   "www-proxy-sjc.oraclecorp.com"
  #   "yum-internal.oracle.com"
  #   "yum.oracle.com"
  # ];
  proxied_ips = [
    "206.223.27.1"
    "206.223.27.2"
    "100.115.65.230"
    "138.1.117.148"
    "100.126.4.64"
    "100.126.5.8"
    "100.112.102.5"
    "138.1.117.148"
    "138.1.117.148"
    "10.242.12.81"
    "100.77.53.69"
    "100.105.153.4"
    "100.114.94.55"
    "138.1.117.148"
    "144.25.106.166"
    "100.77.216.173"
    "100.77.216.177"
    "100.112.22.206"
    "100.105.212.136"
    "100.114.94.31"
    "100.112.124.74"
    "147.154.5.156"
    "100.77.25.241"
    "100.77.38.58"
    "144.25.81.188"
    "100.126.4.64"
    "100.126.5.8"
    "100.112.14.9"
    "100.125.5.67"
    "192.18.204.201"
    "100.77.34.87"
    "100.114.94.139"
    "100.112.125.102"
    "100.77.63.149"
    "100.125.5.163"
    "10.209.64.99"
    "10.23.226.53"
    "10.23.226.53"
    "10.23.226.53"
    "10.68.69.53"
    "10.255.48.38"
    "138.1.51.46"
    "23.40.145.197"
  ];
  redsocks-listen-port = "12345";
  redsocks-config = pkgs.writeText "redsocks.conf" ''
    base {
        log_debug = on;
        log_info = on;
        daemon = off;
        redirector = iptables;
    }

    redsocks {
        local_ip = 127.0.0.1;
        local_port = ${redsocks-listen-port};
        ip = 127.0.0.1;
        port = 8081;
        type = socks5;
    }
  '';
  start-redsocks = pkgs.writeShellScriptBin "start-redsocks" ''
    ${pkgs.redsocks}/bin/redsocks -c ${redsocks-config}
  '';
  start-oracle-tunnel = let
    reserved-ips = [
      # TODO: add ipv6-equivalent
      "0.0.0.0/8"
      "10.0.0.0/8"
      "127.0.0.0/8"
      "169.254.0.0/16"
      "172.16.0.0/12"
      "192.168.0.0/16"
      "224.168.0.0/4"
      "240.168.0.0/4"
    ];
  in
    pkgs.writeShellScriptBin "start-oracle-tunnel" (
      lib.concatStringsSep
      "\n"
      (
        [
          "iptables -t nat -N REDSOCKS || true"
        ]
        ++ map (x: "iptables -t nat -A REDSOCKS -d " + x + " -j RETURN || true") reserved-ips
        ++ [
          "iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports ${redsocks-listen-port} || true"
          "iptables -t nat -A PREROUTING -i docker0 -p tcp -j REDSOCKS --to-ports ${redsocks-listen-port} || true"
        ]
        ++ map (x: "iptables -t nat -A OUTPUT -p tcp -d " + x + "/32 -j REDSOCKS || true") proxied_ips
      )
    );
  stop-oracle-tunnel = pkgs.writeShellScriptBin "stop-oracle-tunnel" ''
    iptables -t nat -F OUTPUT
    iptables -t nat -X REDSOCKS
  '';
in {
  environment.systemPackages = [
    start-redsocks
    start-oracle-tunnel
    stop-oracle-tunnel
  ];

  networking.extraHosts = ''
    206.223.27.1 dns0.openconnect0
    206.223.27.2 dns1.openconnect0
    100.115.65.230 apex.oraclecorp.com
    138.1.117.148 artifacthub-phx.oci.oraclecorp.com
    100.126.4.64 artifactory.oci.oraclecorp.com
    100.126.5.8 artifactory.oci.oraclecorp.com
    100.112.102.5 badge.oraclecorp.com
    138.1.117.148 cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com
    138.1.117.148 cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com
    10.242.12.81 cegbu.docker.oraclecorp.com
    100.77.53.69 cegbu.oraclecorp.com
    100.105.153.4 cloudlab.us.oracle.com
    100.114.94.55 confluence.oraclecorp.com
    138.1.117.148 docker-remote.dockerhub-phx.oci.oraclecorp.com
    144.25.106.166 exchange.oraclecorp.com
    100.77.216.173 gbuconfluence.oraclecorp.com
    100.77.216.177 gbujira.oraclecorp.com
    100.112.22.206 global-ebusiness.oraclecorp.com
    100.105.212.136 gps.oracle.com
    100.114.94.31 hrservices.oraclecorp.com
    100.112.124.74 mydesktop.oraclecorp.com
    147.154.5.156 oci-ssp.oracle-ocna.com
    100.77.25.241 ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com
    100.77.38.58 ocitpmpypi.us.oracle.com
    144.25.81.188 ocp.oraclecorp.com
    100.126.4.64 odo-docker-local.artifactory.oci.oraclecorp.com
    100.126.5.8 odo-docker-local.artifactory.oci.oraclecorp.com
    100.112.14.9 oim.oraclecorp.com
    100.125.5.67 permissions.oci.oraclecorp.com
    192.18.204.201 phx-c-csec-awp-01.us5.oraclecloud.com
    100.77.34.87 phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com
    100.114.94.139 pls.appoci.oraclecorp.com
    100.112.125.102 printers.oraclecorp.com
    100.77.63.149 testrail.us.oracle.com
    100.125.5.163 u2f-validator.idp.mc1.oracleiaas.com
    10.209.64.99 utilus.us.oracle.com
    10.23.226.53 www-proxy-adcq7-new.us.oracle.com
    10.23.226.53 www-proxy-adcq7.us.oracle.com
    10.23.226.53 www-proxy-ash7.us.oracle.com
    10.68.69.53 www-proxy-hqdc.us.oracle.com
    10.255.48.38 www-proxy-sjc.oraclecorp.com
    138.1.51.46 yum-internal.oracle.com
    23.40.145.197 yum.oracle.com
  '';
}
