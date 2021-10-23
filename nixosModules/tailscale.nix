{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.services.tailscale;
in
{
  options = {
    services.tailscale.initKey = mkOption {
      type = types.nullOr types.string;
      default = null;
      description = ''
        a tailscale authkey for initialization.
        DO NOT USE A REUSABLE KEY AS IT CAN BE READ FROM THE STORE
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.initKey != null) {
      # create a oneshot job to authenticate to Tailscale
      systemd.services.tailscale-init-auth = {
        description = "Automatic connection to Tailscale";

        # make sure tailscale is running before trying to connect to tailscale
        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];

        # set this service as a oneshot job
        serviceConfig.Type = "oneshot";

        # have the job run this shell script
        script = ''
          # wait for tailscaled to settle
          sleep 2

          # check if we are already authenticated to tailscale
          status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
          if [ $status = "Running" ]; then # if so, then do nothing
            exit 0
          fi

          # otherwise authenticate with tailscale
          ${pkgs.tailscale}/bin/tailscale up -authkey ${cfg.initKey}
        '';
      };
    })

    {
      networking.firewall = {
        allowedUDPPorts = [ cfg.port ];
        # Needed for taildrop to work, may need to be revisited in the future
        # https://forum.tailscale.com/t/taildrop-not-working-when-sending-a-file-from-iphone-to-a-nixos-machine/633/7
        trustedInterfaces = [ cfg.interfaceName ];
      };
    }
  ]);
}
