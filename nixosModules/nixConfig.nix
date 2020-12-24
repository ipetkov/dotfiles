{ pkgs, inputs, ... }:
{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    useSandbox = true;

    # Use our inputs as defaults for nixpkgs/nixos so everything (like nix-env)
    # moves in lockstep. (Note adding a channel will take precedence over this).
    nixPath = [
      "nixos=${inputs.nixos}"
      "nixpkgs=${inputs.nixpkgs}"
    ];
    registry = {
      nixos.flake = inputs.nixos;
      nixpkgs.flake = inputs.nixpkgs;
    };

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
  };
}
