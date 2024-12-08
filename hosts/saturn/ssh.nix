{
  services.openssh = {
    enable = true;
    listenAddesses = [
      {
        addr = "0.0.0.0";
        port = 10101;
      }
    ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
