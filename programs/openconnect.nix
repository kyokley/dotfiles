{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vpn-slice
    openconnect
  ];

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = false;
    extraOptions = {
      disable-ipv6 = true;
      no-proxy = true;
      useragent = "AnyConnect Linux_64 4.10.999999";
      script = "${pkgs.vpn-slice}/bin/vpn-slice --no-host-names --no-ns-hosts oim.oraclecorp.com global-ebusiness.oraclecorp.com";
      # Use below when attempting to find additional host IPs
      # script = "${pkgs.vpn-slice}/bin/vpn-slice oim.oraclecorp.com global-ebusiness.oraclecorp.com";
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
  '';
}
