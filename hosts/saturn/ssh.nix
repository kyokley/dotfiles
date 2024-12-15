let
  sshd_port = 10101;
in
{
  services.openssh = {
    enable = true;
    listenAddresses = [
      {
        addr = "192.168.50.96";
        port = sshd_port;
      }
    ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  systemd.services.sshd.after = [ "network-online.target" ];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "192.168.50.0/24"
    ];
    bantime = "24h";
    bantime-increment = {
      enable = true;
      # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
    jails = {
      sshd.settings = {
        enabled = true;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
    allowedTCPPorts = [
      sshd_port
    ];
  };
}
