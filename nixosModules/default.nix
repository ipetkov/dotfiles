{ ... }:

{
  imports = [
    ./_1password.nix
    ./nixConfig.nix
    ./pihole.nix
    ./tailscale.nix
  ];
}
