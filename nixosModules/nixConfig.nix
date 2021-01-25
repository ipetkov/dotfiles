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

    binaryCaches = ["https://ipetkov.cachix.org"];
    binaryCachePublicKeys = [
      "ipetkov.cachix.org-1:xK9taxnomX0ZVyDmobpZB5AQvuZ+L3q4u7IlRvEtomg="
    ];

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
  };

  # Make our nix store cleanup persistent, meaning if the timer is missed
  # (e.g. because the computer was shut down at the time), then it will
  # be fired at the next start up
  systemd.timers."nix-gc".timerConfig.Persistent = true;
}
