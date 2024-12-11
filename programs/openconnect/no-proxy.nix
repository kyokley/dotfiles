{ pkgs, lib, ... }:
let
  domains = lib.concatStringsSep " " [
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
          "gbuconfluence.oraclecorp.com"
          "gbujira.oraclecorp.com"
          "global-ebusiness.oraclecorp.com"
          "gps.oracle.com"
          "hrservices.oraclecorp.com"
          "ocitpmpypi.us.oracle.com"
          "ocp.oraclecorp.com"
          "odo-docker-local.artifactory.oci.oraclecorp.com"
          "oim.oraclecorp.com"
          "printers.oraclecorp.com"
          "www-proxy-ash7.us.oracle.com"
          "www-proxy-adcq7-new.us.oracle.com"
          "www-proxy-adcq7.us.oracle.com"
          "www-proxy-hqdc.us.oracle.com"
          "www-proxy-sjc.oraclecorp.com"
          "exchange.oraclecorp.com"
          "oci-ssp.oracle-ocna.com"
  ];
in
{
  environment.systemPackages = with pkgs; [
    vpn-slice
    openconnect
  ];

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = lib.mkDefault false;
    extraOptions = {
      disable-ipv6 = true;
      no-proxy = true;
      useragent = "AnyConnect Linux_64 4.10.999999";
      script = "${pkgs.vpn-slice}/bin/vpn-slice --no-host-names --no-ns-hosts ${domains}";
      # Use below when attempting to find additional host IPs. After rebuilding, run the following commands:
      # sudo mv /etc/hosts{,_bak} && sudo cp /etc/static/hosts /etc/hosts && sudo systemctl restart openconnect-openconnect0 && sleep 15 && cat /etc/hosts
      # After determining the host IP, be sure to modify the script above and the extraHosts below
      # script = "${pkgs.vpn-slice}/bin/vpn-slice ${domains}";
    };
    protocol = "anyconnect";
    gateway = "myaccess.oraclevpn.com/exc";
    user = "kyokley_us";
    passwordFile = "/var/lib/secrets/openconnect-passwd";
  };

  networking.extraHosts = ''
    206.223.27.1 dns0.openconnect0          # vpn-slice-openconnect0 AUTOCREATED
    206.223.27.2 dns1.openconnect0          # vpn-slice-openconnect0 AUTOCREATED
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
    100.77.216.173 gbuconfluence.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.177 gbujira.oraclecorp.com           # vpn-slice-openconnect0 AUTOCREATED
    100.112.22.206 global-ebusiness.oraclecorp.com          # vpn-slice-openconnect0 AUTOCREATED
    100.105.212.136 gps.oracle.com          # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.31 hrservices.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.77.38.58 ocitpmpypi.us.oracle.com ocitpmpypi                # vpn-slice-openconnect0 AUTOCREATED
    144.25.81.188 ocp.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.126.4.64 odo-docker-local.artifactory.oci.oraclecorp.com            # vpn-slice-openconnect0 AUTOCREATED
    100.126.5.8 odo-docker-local.artifactory.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.112.14.9 oim.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.112.125.102 printers.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-ash7.us.oracle.com www-proxy-ash7                # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-adcq7-new.us.oracle.com www-proxy-adcq7-new              # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-adcq7.us.oracle.com www-proxy-adcq7              # vpn-slice-openconnect0 AUTOCREATED
    10.68.69.53 www-proxy-hqdc.us.oracle.com www-proxy-hqdc         # vpn-slice-openconnect0 AUTOCREATED
    10.255.48.38 www-proxy-sjc.oraclecorp.com               # vpn-slice-openconnect0 AUTOCREATED
    144.25.106.166 exchange.oraclecorp.com          # vpn-slice-openconnect0 AUTOCREATED
    147.154.5.156 oci-ssp.oracle-ocna.com           # vpn-slice-openconnect0 AUTOCREATED
    '';
}
