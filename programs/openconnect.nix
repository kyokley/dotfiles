{ pkgs, lib, ... }:
let
  domains = lib.concatStringsSep " " [
          "oim.oraclecorp.com"
          "global-ebusiness.oraclecorp.com"
          "badge.oraclecorp.com"
          "printers.oraclecorp.com"
          "gbuconfluence.oraclecorp.com"
          "confluence.oraclecorp.com"
          "cegbu.oraclecorp.com"
          "gbujira.oraclecorp.com"
          "cloudlab.us.oracle.com"
          "hrservices.oraclecorp.com"
          "gps.oracle.com"
          "ocp.oraclecorp.com"
          "artifacthub-phx.oci.oraclecorp.com"
          "artifactory.oci.oraclecorp.com"
          "cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com"
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
    206.223.27.1 dns0.openconnect0    # vpn-slice-openconnect0 AUTOCREATED
    206.223.27.2 dns1.openconnect0    # vpn-slice-openconnect0 AUTOCREATED
    100.112.14.9 oim.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.112.22.206 global-ebusiness.oraclecorp.com    # vpn-slice-openconnect0 AUTOCREATED
    100.112.102.5 badge.oraclecorp.com    # vpn-slice-openconnect0 AUTOCREATED
    100.112.125.102 printers.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.173 gbuconfluence.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.55 confluence.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.77.53.69 cegbu.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.177 gbujira.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.105.153.4 cloudlab.us.oracle.com cloudlab   # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.31 hrservices.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    100.105.212.136 gps.oracle.com    # vpn-slice-openconnect0 AUTOCREATED
    144.25.81.188 ocp.oraclecorp.com    # vpn-slice-openconnect0 AUTOCREATED
    138.1.117.148 artifacthub-phx.oci.oraclecorp.com    # vpn-slice-openconnect0 AUTOCREATED
    100.126.5.8 artifactory.oci.oraclecorp.com    # vpn-slice-openconnect0 AUTOCREATED
    100.126.4.64 artifactory.oci.oraclecorp.com   # vpn-slice-openconnect0 AUTOCREATED
    138.1.117.148 cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com # vpn-slice-openconnect0 AUTOCREATED
    '';
}
