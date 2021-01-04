{ pkgs }:

with pkgs;
{
  swaynagmode = callPackage ./swaynagmode.nix { };
}
