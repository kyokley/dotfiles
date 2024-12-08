{
  services.openssh = {
    enable = true;
    # ports = [
        # 10101
    # ];
    listenAddresses = [
      {
        addr = "192.168.50.96";
        port = 10101;
      }
    ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
