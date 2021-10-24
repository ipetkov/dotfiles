{ config, lib, ... }:

let
  dnsPort = 53;
  httpDefaultPort = 80;
  cfg = config.services.pihole;

  # NET_ADMIN allows for full network control (including making network changes
  # for DHCP broadcasting stuff). NET_BIND_SERVICE simply allows grabbing
  # privileged ports (like 53 or 80).
  networkCapability = if cfg.enableDHCPCap then "NET_ADMIN" else "NET_BIND_SERVICE";
in
{
  options.services.pihole = {
    enable = lib.mkEnableOption "pihole service";

    enableDHCPCap = lib.mkEnableOption "grant network capabilities for DHCP changes";

    containerBackupDns = lib.mkOption {
      type = lib.types.str;
      default = "9.9.9.9";
      description = "a backup DNS server for the container in case DNSMasq has problems starting";
    };

    serverIP = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        the IP address that the HTTP service should listen to (i.e. this should
        probably be the interface of your local network).
      '';
    };

    webPort = lib.mkOption {
      type = lib.types.port;
      default = httpDefaultPort;
      defaultText = toString httpDefaultPort;
      description = ''
        the port that lighttpd should listen to. Change it to another value
        if this host will have more than one HTTP server/virtual host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "${toString dnsPort}:${toString dnsPort}/udp"
        "${toString dnsPort}:${toString dnsPort}/tcp"
        "${toString cfg.webPort}:${toString cfg.webPort}/tcp"
      ];
      volumes = [
        "/var/lib/pihole/:/etc/pihole/"
      ];
      environment = {
        ServerIP = cfg.serverIP;
        TZ = config.time.timeZone;
        WEB_PORT = "${toString cfg.webPort}";
      };
      extraOptions = [
        # Allocate a port in the host's network space so ports opened in the firewall work
        "--network=host"
        "--cap-add=${networkCapability}"
        "--dns=127.0.0.1"
        "--dns=${cfg.containerBackupDns}"
      ];
    };

    networking.firewall.allowedUDPPorts = [ dnsPort ];
    networking.firewall.allowedTCPPorts = [ dnsPort ]
      # Only open up the web port if its the default HTTP port. Otherwise
      # if a different port has been configured, leave it up to the caller if
      # they want to expose the port directly (or use a reverse proxy, etc.).
      ++ lib.lists.optional (cfg.webPort == httpDefaultPort) cfg.webPort;
  };
}
