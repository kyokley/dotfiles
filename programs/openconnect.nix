{ pkgs, lib, ... }:
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
      script = "${pkgs.vpn-slice}/bin/vpn-slice --no-host-names --no-ns-hosts oim.oraclecorp.com global-ebusiness.oraclecorp.com badge.oraclecorp.com";
      # Use below when attempting to find additional host IPs. After rebuilding, run the following commands:
      # sudo mv /etc/hosts{,_bak}
      # sudo cp /etc/static/hosts /etc/hosts
      # sudo systemctl restart openconnect-openconnect0
      # After determining the host IP, be sure to modify the script abov and the extraHosts below
      # script = "${pkgs.vpn-slice}/bin/vpn-slice printers.oraclecorp.com";
    };
    protocol = "anyconnect";
    gateway = "myaccess.oraclevpn.com/exc";
    user = "kyokley_us";
  };

  networking.extraHosts = ''
    206.223.27.1 dns0.openconnect0
    206.223.27.2 dns1.openconnect0
    100.114.26.10 oim.oraclecorp.com
    100.112.22.206 global-ebusiness.oraclecorp.com
    100.112.102.5 badge.oraclecorp.com
  '';
}
