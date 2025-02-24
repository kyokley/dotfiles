{
  pkgs,
  lib,
  ...
}: let
  domains = [
    "dns0.openconnect0 206.223.27.1"
    "dns1.openconnect0 206.223.27.2"
    "apex.oraclecorp.com 100.115.65.230"
    "artifacthub-phx.oci.oraclecorp.com 138.1.117.148"
    "artifactory.oci.oraclecorp.com 100.126.4.64"
    "artifactory.oci.oraclecorp.com 100.126.5.8"
    "badge.oraclecorp.com 100.112.102.5"
    "bug.oraclecorp.com 100.114.94.166"
    "cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com 138.1.117.148"
    "cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com 138.1.117.148"
    "cegbu.docker.oraclecorp.com 10.242.12.81"
    "cegbu.oraclecorp.com 100.77.53.69"
    "cloudlab.us.oracle.com 100.105.153.4"
    "confluence.oraclecorp.com 100.114.94.55"
    "docker-remote.dockerhub-phx.oci.oraclecorp.com 138.1.117.148"
    "exchange.oraclecorp.com 144.25.106.166"
    "gbuconfluence.oraclecorp.com 100.77.216.173"
    "gbujira.oraclecorp.com 100.77.216.177"
    "global-ebusiness.oraclecorp.com 100.112.22.206"
    "gps.oracle.com 100.105.212.136"
    "hrservices.oraclecorp.com 100.114.94.31"
    "mydesktop.oraclecorp.com 100.112.124.74"
    "oci-ssp.oracle-ocna.com 147.154.5.156"
    "ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com 100.77.25.241"
    "ocitpmpypi.us.oracle.com 100.77.38.58"
    "ocp.oraclecorp.com 144.25.81.188"
    "odo-docker-local.artifactory.oci.oraclecorp.com 100.126.4.64"
    "odo-docker-local.artifactory.oci.oraclecorp.com 100.126.5.8"
    "oim.oraclecorp.com 100.112.14.9"
    "permissions.oci.oraclecorp.com 100.125.5.67"
    "phx-c-csec-awp-01.us5.oraclecloud.com 192.18.204.201"
    "phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com 100.77.34.87"
    "pls.appoci.oraclecorp.com 100.114.94.139"
    "printers.oraclecorp.com 100.112.125.102"
    "testrail.us.oracle.com 100.77.63.149"
    "u2f-validator.idp.mc1.oracleiaas.com 100.125.5.163"
    "utilus.us.oracle.com 10.209.64.99"
    "www-proxy-adcq7-new.us.oracle.com 10.23.226.53"
    "www-proxy-adcq7.us.oracle.com 10.23.226.53"
    "www-proxy-ash7.us.oracle.com 10.23.226.53"
    "www-proxy-hqdc.us.oracle.com 10.68.69.53"
    "www-proxy-sjc.oraclecorp.com 10.255.48.38"
    "yum-internal.oracle.com 138.1.51.46"
    "yum.oracle.com 23.40.145.197"
  ];
  redsocks-listen-port = "12345";
  redsocks-config = pkgs.writeText "redsocks.conf" ''
    base {
        log_debug = on;
        log_info = on;
        daemon = off;
        redirector = iptables;
        redsocks_conn_max = 4096;
    }

    redsocks {
        local_ip = 127.0.0.1;
        local_port = ${redsocks-listen-port};
        ip = 127.0.0.1;
        port = 8081;
        type = socks5;
    }
  '';
  start-oracle-tunnel = pkgs.writeShellScriptBin "start-oracle-tunnel" ''
    if [ $(id -u) -ne 0 ]
      then echo Please run this script as root or using sudo!
      exit
    fi
    iptables-save | grep REDSOCKS >/dev/null 2>&1 || configure-oracle-tunnel
    ${pkgs.redsocks}/bin/redsocks -c ${redsocks-config}
  '';
  configure-oracle-tunnel = let
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
    pkgs.writeShellScriptBin "configure-oracle-tunnel" (
      lib.concatStringsSep
      "\n"
      (
        [
          "iptables -t nat -N REDSOCKS || true"
        ]
        ++ map (x: "iptables -t nat -A REDSOCKS -d " + x + " -j RETURN || true") reserved-ips
        ++ [
          "iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports ${redsocks-listen-port} || true"
          ''iptables -t nat -A PREROUTING -i docker0 -p tcp -j DNAT --to-destination 127.0.0.1:${redsocks-listen-port} -m comment --comment "REDSOCKS docker rule" || true''
        ]
        ++ map (host_record: let
          host = lib.splitString " " host_record;
        in "iptables -t nat -A OUTPUT -p tcp -d ${lib.elemAt host 1}/32 -j REDSOCKS || true")
        domains
      )
    );
  stop-oracle-tunnel = pkgs.writeShellScriptBin "stop-oracle-tunnel" ''
    iptables-save | grep -v REDSOCKS | iptables-restore
  '';
in {
  environment.systemPackages = [
    start-oracle-tunnel
    configure-oracle-tunnel
    stop-oracle-tunnel
  ];

  networking.extraHosts = (
    lib.concatStringsSep "\n" (
      map (
        host_record: let
          host = lib.splitString " " host_record;
        in "${lib.elemAt host 1} ${lib.elemAt host 0}"
      )
      domains
    )
  );
}
