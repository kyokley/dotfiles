{
  pkgs,
  lib,
  ...
}: let
  domains = [
    "apex.oraclecorp.com 100.115.65.230"
    "artifacthub-phx.oci.oraclecorp.com 138.1.117.148"
    "artifactory.oci.oraclecorp.com 100.126.4.64"
    "artifactory.oci.oraclecorp.com 100.126.5.8"
    "badge.oraclecorp.com 100.112.102.5"
    "bug.oraclecorp.com 100.114.94.166"
    "cegbu-textura-docker-local.dockerhub-phx.oci.oraclecorp.com 138.1.117.148"
    "cegbu-textura-docker-virtual.dockerhub-phx.oci.oraclecorp.com 138.1.117.148"
    "cegbu.docker.oraclecorp.com 10.242.12.81"
    "cegbu.oraclecorp.com 100.77.53.69"
    "cloudlab.us.oracle.com 100.105.153.4"
    "confluence.oraclecorp.com 100.114.94.55"
    "crepitus3.us.oracle.com 100.77.15.121"
    "dns0.openconnect0 206.223.27.1"
    "dns1.openconnect0 206.223.27.2"
    "docker-remote.dockerhub-phx.oci.oraclecorp.com 138.1.117.148"
    "exchange.oraclecorp.com 144.25.106.166"
    "fido-login-int.identity.oraclecloud.com 131.186.9.131"
    "gbuconfluence.oraclecorp.com 100.77.216.173"
    "gbujira.oraclecorp.com 100.77.216.177"
    "global-ebusiness.oraclecorp.com 100.112.22.206"
    "gps.oracle.com 100.105.212.136"
    "hrservices.oraclecorp.com 100.114.94.31"
    "login.us-phoenix-1.idp.mc1.oracleiaas.com 138.3.108.158"
    "mydesktop.oraclecorp.com 100.112.124.74"
    "oci-ssp.oracle-ocna.com 147.154.5.156"
    "ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com 100.77.25.241"
    "ocitpmpypi.us.oracle.com 100.77.38.58"
    "ocp.oraclecorp.com 144.25.81.188"
    "odo-docker-local.artifactory.oci.oraclecorp.com 100.126.4.64"
    "odo-docker-local.artifactory.oci.oraclecorp.com 100.126.5.8"
    "oim.oraclecorp.com 100.112.14.9"
    "oscs.appoci.oraclecorp.com 100.107.234.80"
    "permissions.oci.oraclecorp.com 100.125.5.67"
    "phx-c-csec-awp-01.us5.oraclecloud.com 192.18.204.201"
    "phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com 100.77.34.87"
    "pls.appoci.oraclecorp.com 100.114.94.139"
    "printers.oraclecorp.com 100.112.125.102"
    "testrail.us.oracle.com 100.77.63.149"
    "u2f-validator.idp.mc1.oracleiaas.com 100.125.5.163"
    "utilus.us.oracle.com 10.209.64.99"
    "www-proxy-adcq7-new.us.oracle.com 10.23.226.53"
    "www-proxy-adcq7.us.oracle.com 10.23.226.53"
    "www-proxy-ash7.us.oracle.com 10.23.226.53"
    "www-proxy-hqdc.us.oracle.com 10.68.69.53"
    "www-proxy-sjc.oraclecorp.com 10.255.48.38"
    "yum-internal.oracle.com 138.1.51.46"
    "yum.oracle.com 23.40.145.197"
  ];
  redsocks-listen-port = "12345";
  redsocks-config = pkgs.writeText "redsocks.conf" ''
    base {
        log_debug = on;
        log_info = on;
        daemon = off;
        redirector = iptables;
        redsocks_conn_max = 4096;
    }

    redsocks {
        local_ip = 127.0.0.1;
        local_port = ${redsocks-listen-port};
        ip = 127.0.0.1;
        port = ${vm-socks-port};
        type = socks5;
    }
  '';
  stop-oracle-tunnel = pkgs.writeShellScriptBin "stop-oracle-tunnel" ''
    ${pkgs.iptables}/bin/iptables-save | grep -v REDSOCKS | ${pkgs.iptables}/bin/iptables-restore
  '';
  start-oracle-tunnel = (
    pkgs.writeShellScriptBin
    "start-oracle-tunnel"
    (
      let
        configure-oracle-tunnel = (
          let
            reserved-ips = [
              # TODO: add ipv6-equivalent
              "0.0.0.0/8"
              "10.0.0.0/8"
              "127.0.0.0/8"
              "169.254.0.0/16"
              "172.16.0.0/12"
              "192.168.0.0/16"
              "224.168.0.0/4"
              "240.168.0.0/4"
            ];
          in
            pkgs.writeShellScriptBin "configure-oracle-tunnel" (
              lib.concatStringsSep
              "\n"
              (
                [
                  "${pkgs.iptables}/bin/iptables -t nat -N REDSOCKS || true"
                ]
                ++ map (x: "${pkgs.iptables}/bin/iptables -t nat -A REDSOCKS -d " + x + " -j RETURN || true") reserved-ips
                ++ [
                  "${pkgs.iptables}/bin/iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports ${redsocks-listen-port} || true"
                  ''${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i docker0 -p tcp -j DNAT --to-destination 127.0.0.1:${redsocks-listen-port} -m comment --comment "REDSOCKS docker rule" || true''
                ]
                ++ map (host_record: let
                  host = lib.splitString " " host_record;
                in "${pkgs.iptables}/bin/iptables -t nat -A OUTPUT -p tcp -d ${lib.elemAt host 1}/32 -j REDSOCKS || true")
                domains
              )
            )
        );
      in ''
        if [ $(id -u) -ne 0 ]
          then echo Please run this script as root or using sudo!
          exit
        fi
        ${pkgs.iptables}/bin/iptables-save | grep REDSOCKS >/dev/null 2>&1 || ${configure-oracle-tunnel}/bin/configure-oracle-tunnel
        ${pkgs.redsocks}/bin/redsocks -c ${redsocks-config}
      ''
    )
  );
  user = "yokley";
  vm-ip = "127.0.0.1";
  vm-port = "3022";
  vm-socks-port = "8081";
in {
  environment.systemPackages = [
    start-oracle-tunnel
    stop-oracle-tunnel
  ];

  networking.extraHosts = (
    lib.concatStringsSep "\n" (
      map (
        host_record: let
          host = lib.splitString " " host_record;
        in "${lib.elemAt host 1} ${lib.elemAt host 0}"
      )
      domains
    )
  );

  systemd.services = {
    oracle-ssh-tunnel = {
      enable = true;
      description = "Tunnels for Oracle VPN";
      serviceConfig = {
        Type = "simple";
        User = "${user}";
      };
      script = toString (
        pkgs.writeShellScript "oracle-ssh-tunnel" ''
          ${pkgs.wait4x}/bin/wait4x tcp ${vm-ip}:${vm-port} --timeout 0 --interval 10s
          ${pkgs.openssh}/bin/ssh -p ${vm-port} ${user}@${vm-ip} -D ${vm-socks-port} -Nv
        ''
      );
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
    };

    redirect-oracle-traffic = {
      enable = true;
      description = "Redsocks redirect Oracle traffic";
      serviceConfig = {
        Type = "simple";
      };
      script = "${start-oracle-tunnel}/bin/start-oracle-tunnel";
      postStop = "${stop-oracle-tunnel}/bin/stop-oracle-tunnel";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
    };
  };
}
