{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vpn-slice
  ];

  networking.openconnect.interfaces.openconnect0 = {
    autoStart = false;
    extraOptions = {
      disable-ipv6 = true;
      no-proxy = true;
      useragent = "AnyConnect Linux_64 4.10.999999";
      script = "${pkgs.vpn-slice}/bin/vpn-slice oim.oraclecorp.com";
    };
    protocol = "anyconnect";
    gateway = "myaccess.oraclevpn.com";
    user = "kyokley_us";
  };
}
