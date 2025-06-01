{ lib, ... }:

{
  imports = [
    ./_1password.nix
    ./knownHosts.nix
    ./nixConfig.nix
    ./pihole.nix
    ./tailscale.nix
    ./unfree.nix
    ./zfs-send.nix
  ];

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
