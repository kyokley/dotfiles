{
  pkgs,
  lib,
  ...
}: let
  csd-openssl-conf = builtins.toFile "csd-openssl-conf" ''
    openssl_conf = openssl_init

    [openssl_init]
    ssl_conf = ssl_sect

    [ssl_sect]
    system_default = system_default_sect

    [system_default_sect]
    Options = UnsafeLegacyRenegotiation
  '';
  csd-post-script = ''
    # Cisco Anyconnect CSD wrapper for OpenConnect
    #
    # Instead of actually downloading and spawning the hostscan trojan,
    # this script posts results directly. Ideally we would work out how to
    # interpret the DES-encrypted (yay Cisco!) tables.dat and basically
    # reimplement the necessary parts hostscan itself. But prepackaged
    # answers, tuned to match what the VPN server currently wants to see,
    # will work for most people. Of course it's perfectly possible to make
    # this tell the truth and not just give prepackaged answers, and most
    # people should do that rather than deliberately circumventing their
    # server's security policy with lies. This script exists as an example
    # to work from.

    # set -x

    if ! ${pkgs.xmlstarlet}/bin/xmlstarlet --version > /dev/null 2>&1; then
        echo "************************************************************************" >&2
        echo "WARNING: xmlstarlet not found in path; CSD token extraction may not work" >&2
        echo "************************************************************************" >&2
        unset XMLSTARLET
    else
        XMLSTARLET=true
    fi

    # cURL 7.39 (https://bugzilla.redhat.com/show_bug.cgi?id=1195771)
    # is required to support pin-based certificate validation. Must set this
    # to true if using an earlier version of cURL.

    MISSING_OPTION_PINNEDPUBKEY=false
    if [[ "$MISSING_OPTION_PINNEDPUBKEY" == "true" ]]; then
        echo "*********************************************************************" >&2
        echo "WARNING: running insecurely; will not validate CSD server certificate" >&2
        echo "*********************************************************************" >&2
        PINNEDPUBKEY="-k"
    elif [[ -z "$CSD_SHA256" ]]; then
        # We must be running with a version of OpenConnect prior to v8.00 if CSD_SHA256
        # is unset. In that case, fallback to cURL's default certificate validation so
        # as to fail-closed rather than fail-open in the case of an unknown or untrusted
        # server certificate.
        PINNEDPUBKEY=""
    else
        # Validate certificate using pin-sha256 value in CSD_SHA256. OpenConnect v8.00
        # and newer releases set the CSD_SHA256 variable unconditionally.
        PINNEDPUBKEY="-k --pinnedpubkey sha256//$CSD_SHA256"
    fi


    export RESPONSE=$(mktemp /tmp/csdresponseXXXXXXX)
    export RESULT=$(mktemp /tmp/csdresultXXXXXXX)
    trap 'rm $RESPONSE $RESULT' EXIT


    cat >> $RESPONSE <<EOF
    endpoint.os.version="$(uname -s)";
    endpoint.os.servicepack="$(uname -r)";
    endpoint.os.architecture="$(uname -m)";
    endpoint.policy.location="Default";
    endpoint.device.protection="none";
    endpoint.device.protection_version="3.1.03103";
    endpoint.device.hostname="$(hostname)";
    endpoint.device.MAC["FFFF.FFFF.FFFF"]="true";
    endpoint.device.protection_extension="3.6.4900.2";
    endpoint.fw["IPTablesFW"]={};
    endpoint.fw["IPTablesFW"].exists="true";
    endpoint.fw["IPTablesFW"].description="IPTables (Linux)";
    endpoint.fw["IPTablesFW"].version="1.6.1";
    endpoint.fw["IPTablesFW"].enabled="ok";
    EOF

    for port in 9217 139 53 22 631 445 9216; do
        cat >> $RESPONSE <<EOF ;
    endpoint.device.port["$port"]="true";
    endpoint.device.tcp4port["$port"]="true";
    endpoint.device.tcp6port["$port"]="true";
    EOF
    done

    shift

    TICKET=
    STUB=0

    while [ "$1" ]; do
        if [ "$1" == "-ticket" ];   then shift; TICKET=''${1//''\\"/}; fi
        if [ "$1" == "-stub" ];     then shift; STUB=''${1//''\\"/}; fi
        shift
    done

    URL="https://$CSD_HOSTNAME/+CSCOE+/sdesktop/token.xml?ticket=$TICKET&stub=$STUB"
    if [ -n "$XMLSTARLET" ]; then
        TOKEN=$(OPENSSL_CONF=${csd-openssl-conf} ${pkgs.curl}/bin/curl $PINNEDPUBKEY -s "$URL"  | ${pkgs.xmlstarlet}/bin/xmlstarlet sel -t -v /hostscan/token)
    else
        TOKEN=$(OPENSSL_CONF=${csd-openssl-conf} ${pkgs.curl}/bin/curl $PINNEDPUBKEY -s "$URL" | sed -n '/<token>/s^.*<token>\(.*\)</token>^\1^p' )
    fi

    if [ -n "$XMLSTARLET" ]; then
        URL="https://$CSD_HOSTNAME/CACHE/sdesktop/data.xml"

        OPENSSL_CONF=${csd-openssl-conf} ${pkgs.curl}/bin/curl $PINNEDPUBKEY -s "$URL" | ${pkgs.xmlstarlet}/bin/xmlstarlet sel -t -v '/data/hostscan/field/@value' -n | while read -r ENTRY; do
    	# XX: How are ' and , characters escaped in this?
    	TYPE="$(sed "s/^'\(.*\)','\(.*\)','\(.*\)'$/\1/" <<< "$ENTRY")"
    	NAME="$(sed "s/^'\(.*\)','\(.*\)','\(.*\)'$/\2/" <<< "$ENTRY")"
    	VALUE="$(sed "s/^'\(.*\)','\(.*\)','\(.*\)'$/\3/" <<< "$ENTRY")"

    	if [ "$TYPE" != "$ENTRY" ]; then
    	    case "$TYPE" in
    		File)
    		    BASENAME="$(basename "$VALUE")"
    		    cat >> $RESPONSE <<EOF
    endpoint.file["$NAME"]={};
    endpoint.file["$NAME"].path="$VALUE";
    endpoint.file["$NAME"].name="$BASENAME";
    EOF
    		    TS=$(stat -c %Y "$VALUE" 2>/dev/null)
    		    if [ "$TS" = "" ]; then
    		    cat >> $RESPONSE <<EOF
    endpoint.file["$NAME"].exists="false";
    EOF
    		    else
    			LASTMOD=$(( $(date +%s) - $TS ))
    		    cat >> $RESPONSE <<EOF
    endpoint.file["$NAME"].exists="true";
    endpoint.file["$NAME"].lastmodified="$LASTMOD";
    endpoint.file["$NAME"].timestamp="$TS";
    EOF
    			CRC32=$(crc32 "$VALUE")
    			if [ "$CRC32" != "" ]; then
    		    cat >> $RESPONSE <<EOF
    endpoint.file["$NAME"].crc32="0x$CRC32";
    EOF
    			fi
    		    fi
    		    ;;

    		Process)
    		    if pidof "$VALUE" &> /dev/null; then
    			EXISTS=true
    		    else
    			EXISTS=false
    		    fi
    		    cat >> $RESPONSE <<EOF
    endpoint.process["$NAME"]={};
    endpoint.process["$NAME"].name="$VALUE";
    endpoint.process["$NAME"].exists="$EXISTS";
    EOF
    		    ## XX: Add '.path' if it's running?
    		    ;;

    		Registry)
    		    # We silently ignore registry entry requests
    		    ;;

    		*)
    		    echo "Unhandled hostscan element of type '$TYPE': '$NAME'/'$VALUE'"
    		    ;;
    	    esac
    	else
    	    echo "Unhandled hostscan field '$ENTRY'"
    	fi
        done
    fi

    COOKIE_HEADER="Cookie: sdesktop=$TOKEN"
    CONTENT_HEADER="Content-Type: text/xml"
    URL="https://$CSD_HOSTNAME/+CSCOE+/sdesktop/scan.xml?reusebrowser=1"
    OPENSSL_CONF=${csd-openssl-conf} ${pkgs.curl}/bin/curl $PINNEDPUBKEY -s -H "$CONTENT_HEADER" -H "$COOKIE_HEADER" -H 'Expect: ' --data-binary @$RESPONSE "$URL" > $RESULT

    cat $RESULT || :

    exit 0
  '';
  domains = lib.concatStringsSep " " [
    "apex.oraclecorp.com"
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
    "exchange.oraclecorp.com"
    "gbuconfluence.oraclecorp.com"
    "gbujira.oraclecorp.com"
    "global-ebusiness.oraclecorp.com"
    "gps.oracle.com"
    "hrservices.oraclecorp.com"
    "mydesktop.oraclecorp.com"
    "oci-ssp.oracle-ocna.com"
    "ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com"
    "ocitpmpypi.us.oracle.com"
    "ocp.oraclecorp.com"
    "odo-docker-local.artifactory.oci.oraclecorp.com"
    "oim.oraclecorp.com"
    "permissions.oci.oraclecorp.com"
    "phx-c-csec-awp-01.us5.oraclecloud.com"
    "phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com"
    "pls.appoci.oraclecorp.com"
    "printers.oraclecorp.com"
    "testrail.us.oracle.com"
    "u2f-validator.idp.mc1.oracleiaas.com"
    "utilus.us.oracle.com"
    "www-proxy-adcq7-new.us.oracle.com"
    "www-proxy-adcq7.us.oracle.com"
    "www-proxy-ash7.us.oracle.com"
    "www-proxy-hqdc.us.oracle.com"
    "www-proxy-sjc.oraclecorp.com"
    "yum-internal.oracle.com"
  ];
  no-hostnames-openconnect-config = let
    csd-wrapper = toString (
      pkgs.writeShellScript "csd-post" csd-post-script
    );
  in pkgs.writeText "openconnect-config" ''
    interface=openconnect0
    protocol=anyconnect
    user=kyokley_us
    csd-wrapper=${csd-wrapper}
    disable-ipv6
    no-proxy
    script=${pkgs.vpn-slice}/bin/vpn-slice --no-host-names --no-ns-hosts ${domains}
    os=linux-64
    useragent=AnyConnect
  '';
  hostnames-openconnect-config = let
    csd-wrapper = toString (
      pkgs.writeShellScript "csd-post" csd-post-script
    );
  in pkgs.writeText "openconnect-config" ''
    interface=openconnect0
    protocol=anyconnect
    user=kyokley_us
    csd-wrapper=${csd-wrapper}
    disable-ipv6
    no-proxy
    script=${pkgs.vpn-slice}/bin/vpn-slice ${domains}
    useragent=AnyConnect Linux_64 4.10.999999
  '';
  vpn-connect = pkgs.writeShellScriptBin "vpn-connect" ''
    sudo ${pkgs.openconnect}/bin/openconnect --config=${no-hostnames-openconnect-config} myaccess.oraclevpn.com
  '';
  new-domain-vpn-connect = pkgs.writeShellScriptBin "new-domain-vpn-connect" ''
    sudo ${pkgs.openconnect}/bin/openconnect --config=${hostnames-openconnect-config} myaccess.oraclevpn.com
  '';
in {
  environment.systemPackages = with pkgs; [
    vpn-slice
    openconnect
    xmlstarlet
    curl
    vpn-connect
    # Use below when attempting to find additional host IPs. After rebuilding, run the following commands:
    # sudo mv /etc/hosts{,_bak} && sudo cp /etc/static/hosts /etc/hosts && new-domain-vpn-connect
    # Followed by:
    # cat /etc/hosts
    # After determining the host IP, be sure to modify the script above and the extraHosts below
    new-domain-vpn-connect
  ];

  networking.extraHosts = ''
    206.223.27.1 dns0.openconnect0          # vpn-slice-openconnect0 AUTOCREATED
    206.223.27.2 dns1.openconnect0          # vpn-slice-openconnect0 AUTOCREATED
    100.115.65.230 apex.oraclecorp.com              # vpn-slice-openconnect0 AUTOCREATED
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
    144.25.106.166 exchange.oraclecorp.com          # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.173 gbuconfluence.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.77.216.177 gbujira.oraclecorp.com           # vpn-slice-openconnect0 AUTOCREATED
    100.112.22.206 global-ebusiness.oraclecorp.com          # vpn-slice-openconnect0 AUTOCREATED
    100.105.212.136 gps.oracle.com          # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.31 hrservices.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.112.124.74 mydesktop.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    147.154.5.156 oci-ssp.oracle-ocna.com           # vpn-slice-openconnect0 AUTOCREATED
    100.77.25.241 ociautojenkins01.snphxprshared1.gbucdsint02phx.oraclevcn.com              # vpn-slice-openconnect0 AUTOCREATED
    100.77.38.58 ocitpmpypi.us.oracle.com ocitpmpypi                # vpn-slice-openconnect0 AUTOCREATED
    144.25.81.188 ocp.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.126.4.64 odo-docker-local.artifactory.oci.oraclecorp.com            # vpn-slice-openconnect0 AUTOCREATED
    100.126.5.8 odo-docker-local.artifactory.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    100.112.14.9 oim.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.125.5.67 permissions.oci.oraclecorp.com             # vpn-slice-openconnect0 AUTOCREATED
    192.18.204.201 phx-c-csec-awp-01.us5.oraclecloud.com            # vpn-slice-openconnect0 AUTOCREATED
    100.77.34.87 phxtpmae791.snphxprshared1.gbucdsint02phx.oraclevcn.com            # vpn-slice-openconnect0 AUTOCREATED
    100.114.94.139 pls.appoci.oraclecorp.com                # vpn-slice-openconnect0 AUTOCREATED
    100.112.125.102 printers.oraclecorp.com         # vpn-slice-openconnect0 AUTOCREATED
    100.77.63.149 testrail.us.oracle.com testrail           # vpn-slice-openconnect0 AUTOCREATED
    100.125.5.163 u2f-validator.idp.mc1.oracleiaas.com              # vpn-slice-openconnect0 AUTOCREATED
    10.209.64.99 utilus.us.oracle.com utilus                # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-adcq7-new.us.oracle.com www-proxy-adcq7-new              # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-adcq7.us.oracle.com www-proxy-adcq7              # vpn-slice-openconnect0 AUTOCREATED
    10.23.226.53 www-proxy-ash7.us.oracle.com www-proxy-ash7                # vpn-slice-openconnect0 AUTOCREATED
    10.68.69.53 www-proxy-hqdc.us.oracle.com www-proxy-hqdc         # vpn-slice-openconnect0 AUTOCREATED
    10.255.48.38 www-proxy-sjc.oraclecorp.com               # vpn-slice-openconnect0 AUTOCREATED
    138.1.51.46 yum-internal.oracle.com             # vpn-slice-openconnect0 AUTOCREATED
  '';
}
