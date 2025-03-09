{ config, lib, pkgs, ... }:

let
  defaultDnsPort = 53;
  httpDefaultPort = 80;
  cfg = config.dotfiles.services.pihole;

  # NET_ADMIN allows for full network control (including making network changes
  # for DHCP broadcasting stuff). NET_BIND_SERVICE simply allows grabbing
  # privileged ports (like 53 or 80).
  networkCapability = if cfg.enableDHCPCap then "NET_ADMIN" else "NET_BIND_SERVICE";
in
{
  options.dotfiles.services.pihole = {
    enable = lib.mkEnableOption "pihole service";

    niceness = lib.mkOption {
      type = lib.types.ints.between (-20) 19;
      default = -15;
      description = "the niceness level of the process: https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Nice=";
    };

    enableDHCPCap = lib.mkEnableOption "grant network capabilities for DHCP changes";

    containerBackupDns = lib.mkOption {
      type = lib.types.str;
      default = "9.9.9.9";
      description = "a backup DNS server for the container in case DNSMasq has problems starting";
    };

    hostDnsPort = lib.mkOption {
      type = lib.types.port;
      default = defaultDnsPort;
      defaultText = toString defaultDnsPort;
      description = ''
        the (host) port that will be mapped to the docker image's DNS port
      '';
    };

    pullAt = lib.mkOption {
      type = lib.types.str;
      # Pihole images are updated monthly, so run half way through the month
      default = "*-*-15 00:00:00";
      description = "a systemd.time(7) compatible option for how often the image should be pulled";
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
    systemd.services."docker-pihole".serviceConfig.Nice = cfg.niceness;
    virtualisation.oci-containers.containers.pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "${toString cfg.hostDnsPort}:${toString defaultDnsPort}/udp"
        "${toString cfg.hostDnsPort}:${toString defaultDnsPort}/tcp"
        "${toString cfg.webPort}:${toString cfg.webPort}/tcp"
      ];
      volumes = [
        "/var/lib/pihole/:/etc/pihole/"
      ];
      environment = {
        TZ = config.time.timeZone;
        FTLCONF_webserver_port = "${toString cfg.webPort}";
      };
      extraOptions = [
        "--cap-add=${networkCapability}"
        "--dns=${cfg.containerBackupDns}"
      ]
      # Allocate a port in the host's network space so ports opened in the firewall work
      ++ (lib.lists.optional (cfg.hostDnsPort == defaultDnsPort) "--network=host");
    };

    systemd.services.pihole-update-image = {
      script = ''
        set -e
        ${pkgs.docker}/bin/docker pull pihole/pihole:latest
        systemctl restart docker-pihole.service
      '';

      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.timers.pihole-update-image = {
      wantedBy = [ "timers.target" ];
      partOf = [ "pihole-update-image.service" ];
      timerConfig = {
        Persistent = true;
        OnCalendar = cfg.pullAt;
      };
    };

    # Only open up the hostDnsPort if it's the default DNS port
    # otherwise let the caller sort it out
    networking.firewall.allowedUDPPorts =
      lib.lists.optional (cfg.hostDnsPort == defaultDnsPort) cfg.hostDnsPort;
    networking.firewall.allowedTCPPorts =
      (lib.lists.optional (cfg.hostDnsPort == defaultDnsPort) cfg.hostDnsPort)

      # Only open up the web port if its the default HTTP port. Otherwise
      # if a different port has been configured, leave it up to the caller if
      # they want to expose the port directly (or use a reverse proxy, etc.).
      ++ lib.lists.optional (cfg.webPort == httpDefaultPort) cfg.webPort;
  };
}
