{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types;

  cfg = config.services.photoprism;
in
{
  options.services.photoprism = {
    enable = lib.mkEnableOption "photoprism service";
    allowExposedHttpPort = lib.mkEnableOption "permit photoprism's http port to be exposed";

    additionalHardwareDevices = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "what additional devices to make available to photoprism";
    };

    ffmpegEncoder = lib.mkOption {
      type = types.str;
      default = "software";
      description = "what (possibly hardware-accellerated) encoder to use";
    };

    internalHttpPort = lib.mkOption rec {
      type = types.port;
      default = 2342;
      defaultText = toString default;
      description = ''
        the port that photoprism should (internally) listen to. Change it to another
        value if this port is already reserved. Nginx will be configured to forward
        virtual traffic there
      '';
    };

    logLevel = lib.mkOption {
      type = types.str;
      default = "info";
      description = "the level at which to emit logs";
    };

    niceness = lib.mkOption {
      type = types.ints.between (-20) 19;
      default = 10;
      description = "the niceness level of the process: https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Nice=";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.photoprism;
      defaultText = "pkgs.photoprism";
      description = "Package providing photoprism";
    };

    siteCaption = lib.mkOption {
      type = types.str;
      default = "AI-Powered Photos App";
      description = "the site caption";
    };

    siteDescription = lib.mkOption {
      type = types.str;
      default = "";
      description = "the site description";
    };

    siteDomain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "the (client accessible) domain for the service";
    };

    siteDomainTls = mkOption {
      type = types.bool;
      default = true;
      description = "does the site domain use TLS";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          message = "photoprism's internal http port (${toString cfg.internalHttpPort}) is exposed in the firewall!";
          assertion = !cfg.allowExposedHttpPort -> !lib.any
            (p: p == cfg.internalHttpPort)
            config.networking.firewall.allowedTCPPorts;
        }
        {
          message = "photoprism's internal http port (${toString cfg.internalHttpPort}) is within an exposed firewall range!";
          assertion = !cfg.allowExposedHttpPort -> !lib.any
            ({ from, to }: from >= cfg.internalHttpPort || cfg.internalHttpPort <= to)
            config.networking.firewall.allowedTCPPortRanges;
        }
      ];

      systemd.services.photoprism = {
        wantedBy = [ "multi-user.target" ];
        script = ''
          set -e
          cd "$STATE_DIRECTORY"
          exec ${cfg.package}/bin/photoprism start
        '';

        environment = {
          PHOTOPRISM_AUTH_MODE = "password";
          PHOTOPRISM_ADMIN_USER = "admin";
          PHOTOPRISM_ADMIN_PASSWORD = "insecure"; # Initial password, remember to change it!

          PHOTOPRISM_LOG_LEVEL = cfg.logLevel;

          PHOTOPRISM_DEFAULTS_YAML = "/dev/null";
          PHOTOPRISM_ORIGINALS_PATH = "./originals";
          PHOTOPRISM_ORIGINALS_LIMIT = "-1";
          PHOTOPRISM_STORAGE_PATH = "./storage";
          PHOTOPRISM_IMPORT_PATH = "./import";

          PHOTOPRISM_SITE_URL =
            if (cfg.siteDomain != null)
            then "http${lib.optionalString cfg.siteDomainTls "s"}://${cfg.siteDomain}"
            else "http://127.0.0.1:${toString cfg.internalHttpPort}";
          PHOTOPRISM_SITE_CAPTION = cfg.siteCaption;
          PHOTOPRISM_SITE_DESCRIPTION = cfg.siteDescription;

          PHOTOPRISM_TRUSTED_PROXY = "127.0.0.0/8"; # Trust loopback interface
          PHOTOPRISM_HTTP_COMPRESSION = "gzip";
          PHOTOPRISM_HTTP_HOST = "127.0.0.1"; # Bind to the localhost interface
          PHOTOPRISM_HTTP_PORT = toString cfg.internalHttpPort;

          PHOTOPRISM_DATABASE_DRIVER = "sqlite";
          PHOTOPRISM_DATABASE_DSN = "./db.sqlite";

          PHOTOPRISM_FFMPEG_ENCODER = cfg.ffmpegEncoder;
        };

        serviceConfig = {
          CapabilityBoundingSet = "";
          DeviceAllow = cfg.additionalHardwareDevices;
          DevicePolicy = "closed";
          DynamicUser = "yes";
          LockPersonality = true;
          /* MemoryDenyWriteExecute = true; */ # tensorflow apparently crashes without this
          Nice = cfg.niceness;
          PrivateDevices = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          Restart = "on-failure";
          RestartSec = "5m"; # Try to avoid flapping too hard if something is really wrong
          RestrictAddressFamilies = "AF_INET";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RuntimeDirectoryMode = "0500";
          RuntimeDirectory = "photoprism";
          StateDirectoryMode = "0700";
          StateDirectory = "photoprism";
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@clock @debug @module @mount @raw-io @reboot @swap @privileged @cpu-emulation @obsolete"; # Apparently needs @resources
          UMask = "0077";
          WorkingDirectory = "${cfg.package}"; # Note overridden above
        };
      };
    }

    (lib.mkIf (cfg.siteDomain != null) {
      services.nginx.virtualHosts."${cfg.siteDomain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.internalHttpPort}";
          proxyWebsockets = true;
          extraConfig = ''
            # Indexing photos can take a while, raise the timeout here so
            # the client doesn't think the upload has failed
            proxy_read_timeout 30m;

            # Extra settings from https://docs.photoprism.app/getting-started/advanced/nginx-proxy-setup/
            client_max_body_size 500M;
            proxy_buffering off;
          '';
        };
      };
    })
  ]);
}
