{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.tailscale;
in
{
  config = mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [ cfg.port ];
      # Needed for taildrop to work, may need to be revisited in the future
      # https://forum.tailscale.com/t/taildrop-not-working-when-sending-a-file-from-iphone-to-a-nixos-machine/633/7
      trustedInterfaces = [ cfg.interfaceName ];
      checkReversePath = "loose";
    };
  };
}
