{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.services.tailscale;

  # https://github.com/NixOS/nixpkgs/pull/442245
  # https://nixpk.gs/pr-tracker.html?pr=442245
  pinned = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/8eb28adfa3dc4de28e792e3bf49fcf9007ca8ac9.tar.gz";
    sha256 = "sha256-NOrUtIhTkIIumj1E/Rsv1J37Yi3xGStISEo8tZm3KW4=";
  };

  chosenPkgs =
    if pkgs.tailscale.version == "1.86.4" then
      import pinned { inherit (config.nixpkgs) system; }
    else
      pkgs;
in
{
  config = mkIf cfg.enable {
    services.tailscale.package = chosenPkgs.tailscale;

    networking.firewall = {
      allowedUDPPorts = [ cfg.port ];
      # Needed for taildrop to work, may need to be revisited in the future
      # https://forum.tailscale.com/t/taildrop-not-working-when-sending-a-file-from-iphone-to-a-nixos-machine/633/7
      trustedInterfaces = [ cfg.interfaceName ];
      checkReversePath = "loose";
    };
  };
}
