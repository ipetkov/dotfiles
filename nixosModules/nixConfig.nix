{ pkgs, inputs, ... }:
{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    useSandbox = true;

    # Use our inputs as defaults for nixpkgs/nixos so everything (like nix-env)
    # moves in lockstep. (Note adding a channel will take precedence over this).
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };

    binaryCaches = ["https://ipetkov.cachix.org"];
    binaryCachePublicKeys = [
      "ipetkov.cachix.org-1:xK9taxnomX0ZVyDmobpZB5AQvuZ+L3q4u7IlRvEtomg="
    ];

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
      persistent = true;
    };

    optimise.dates = ["monthly"];
  };
}
