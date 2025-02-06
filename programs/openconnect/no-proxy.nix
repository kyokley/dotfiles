{
  pkgs,
  lib,
  ...
}: let
  domains = lib.concatStringsSep " " [
    "apex.oraclecorp.com"
    "artifacthub-phx.oci.oraclecorp.com"
    "artifactory.oci.oraclecorp.com"
    "badge.oraclecorp.com"
    "cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com"
    "cegbu-textura-docker-virtual.dockerhub-den.oraclecorp.com"
    "cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com"
    "cegbu.docker.oraclecorp.com"
    "cegbu.oraclecorp.com"
    "cloudlab.us.oracle.com"
    "confluence.oraclecorp.com"
    "docker-remote.dockerhub-phx.oci.oraclecorp.com"
    "exchange.oraclecorp.com"
    "gbuconfluence.oraclecorp.com"
    "gbujira.oraclecorp.com"
    "global-ebusiness.oraclecorp.com"
    "gps.oracle.com"
    "hrservices.oraclecorp.com"
    "mydesktop.oraclecorp.com"
    "oci-ssp.oracle-ocna.com"
    "ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com"
    "ocitpmpypi.us.oracle.com"
    "ocp.oraclecorp.com"
    "odo-docker-local.artifactory.oci.oraclecorp.com"
    "oim.oraclecorp.com"
    "permissions.oci.oraclecorp.com"
    "phx-c-csec-awp-01.us5.oraclecloud.com"
    "phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com"
    "pls.appoci.oraclecorp.com"
    "printers.oraclecorp.com"
    "testrail.us.oracle.com"
    "u2f-validator.idp.mc1.oracleiaas.com"
    "utilus.us.oracle.com"
    "www-proxy-adcq7-new.us.oracle.com"
    "www-proxy-adcq7.us.oracle.com"
    "www-proxy-ash7.us.oracle.com"
    "www-proxy-hqdc.us.oracle.com"
    "www-proxy-sjc.oraclecorp.com"
    "yum-internal.oracle.com"
  ];
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
  ];
in {
  networking.firewall.extraCommands = (
    lib.concatStringsSep
    "\n"
    (
      [
        "iptables -t nat -N REDSOCKS"
        "iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN"
        "iptables -t -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345"
      ]
      ++ map (x: "iptables -t nat -A OUTPUT -p tcp -d " + x + "/32 -j REDSOCKS") proxied_ips
    )
  );

  services.redsocks = {
    enable = true;
    redsocks = [{
      ip = "127.0.0.1";
      port = 12345;
      type = "socks5";
      proxy = "127.0.0.1:8081";
    }];
  };

  networking.extraHosts = ''
    206.223.27.1 dns0.openconnect0          # vpn-slice-openconnect0 AUTOCREATED
    206.223.27.2 dns1.openconnect0          # vpn-slice-openconnect0 AUTOCREATED
    100.115.65.230 apex.oraclecorp.com              # vpn-slice-openconnect0 AUTOCREATED
    138.1.117.148 artifacthub-phx.oci.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.126.4.64 artifactory.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.126.5.8 artifactory.oci.oraclecorp.com              # vpn-slice-openconnect0 AUTOCREATED
    100.112.102.5 badge.oraclecorp.com              # vpn-slice-openconnect0 AUTOCREATED
    138.1.117.148 cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com               # vpn-slice-openconnect0 AUTOCREATED
    138.1.117.148 cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    10.242.12.81 cegbu.docker.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.77.53.69 cegbu.oraclecorp.com               # vpn-slice-openconnect0 AUTOCREATED
    100.105.153.4 cloudlab.us.oracle.com cloudlab           # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.55 confluence.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    138.1.117.148 docker-remote.dockerhub-phx.oci.oraclecorp.com            # vpn-slice-openconnect0 AUTOCREATED
    144.25.106.166 exchange.oraclecorp.com          # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.173 gbuconfluence.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.177 gbujira.oraclecorp.com           # vpn-slice-openconnect0 AUTOCREATED
    100.112.22.206 global-ebusiness.oraclecorp.com          # vpn-slice-openconnect0 AUTOCREATED
    100.105.212.136 gps.oracle.com          # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.31 hrservices.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.112.124.74 mydesktop.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    147.154.5.156 oci-ssp.oracle-ocna.com           # vpn-slice-openconnect0 AUTOCREATED
    100.77.25.241 ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com              # vpn-slice-openconnect0 AUTOCREATED
    100.77.38.58 ocitpmpypi.us.oracle.com ocitpmpypi                # vpn-slice-openconnect0 AUTOCREATED
    144.25.81.188 ocp.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.126.4.64 odo-docker-local.artifactory.oci.oraclecorp.com            # vpn-slice-openconnect0 AUTOCREATED
    100.126.5.8 odo-docker-local.artifactory.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.112.14.9 oim.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.125.5.67 permissions.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    192.18.204.201 phx-c-csec-awp-01.us5.oraclecloud.com            # vpn-slice-openconnect0 AUTOCREATED
    100.77.34.87 phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com            # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.139 pls.appoci.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.112.125.102 printers.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.77.63.149 testrail.us.oracle.com testrail           # vpn-slice-openconnect0 AUTOCREATED
    100.125.5.163 u2f-validator.idp.mc1.oracleiaas.com              # vpn-slice-openconnect0 AUTOCREATED
    10.209.64.99 utilus.us.oracle.com utilus                # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-adcq7-new.us.oracle.com www-proxy-adcq7-new              # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-adcq7.us.oracle.com www-proxy-adcq7              # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-ash7.us.oracle.com www-proxy-ash7                # vpn-slice-openconnect0 AUTOCREATED
    10.68.69.53 www-proxy-hqdc.us.oracle.com www-proxy-hqdc         # vpn-slice-openconnect0 AUTOCREATED
    10.255.48.38 www-proxy-sjc.oraclecorp.com               # vpn-slice-openconnect0 AUTOCREATED
    138.1.51.46 yum-internal.oracle.com             # vpn-slice-openconnect0 AUTOCREATED
  '';
}
