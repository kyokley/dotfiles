{username, ...}: let
  # Need to listen on port 22 for Nix remote build
  sshd_port = 22;
in {
  services.openssh = {
    enable = true;
    openFirewall = true;
    listenAddresses = [
      {
        addr = "192.168.50.31";
        port = sshd_port;
      }
    ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.services.sshd = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  users.users.${username}.openssh.authorizedKeys = {
    keyFiles = [
      ../mars/mars.pub
      ../mars/mars-root.pub
      ../dioxygen/dioxygen.pub
      ../dioxygen/dioxygen-root.pub
      ./saturn.pub
      ./saturn-root.pub
    ];
  };
}
