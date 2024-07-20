{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.dotfiles.nix;
in
{
  # The nixpkgs source is kinda large (87MB at this time, but constantly growing)
  # so allow machines (i.e. non-desktops) to opt out of adding it to the NIX_PATH/flake registry
  # to avoid having to copy it over with all deployments
  options.dotfiles.nix.enableSetNixPathAndFlakeRegistry = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = true;
    description = "Whether to add nixpkgs to nixPath and flake registry";
  };

  config = lib.mkMerge [
    ({
      nix = {
        package = pkgs.lixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
          keep-outputs = true
          keep-derivations = true
        '';

        settings = {
          sandbox = true;

          trusted-substituters = [
            "https://cache.ipetkov.dev/isc"
            "https://crane.cachix.org"
            "https://ipetkov.cachix.org"
          ];

          trusted-public-keys = [
            "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
            "ipetkov.cachix.org-1:xK9taxnomX0ZVyDmobpZB5AQvuZ+L3q4u7IlRvEtomg="
            "isc:b6qs2oRmB0HiJ0KCePMrv40lalsp6+e8eZRQRkXrMIc="
          ];
        };

        gc = {
          automatic = true;
          # Run on the 7th of the month: could take up a lot of I/O, so avoid
          # running at the same time as other "monthly" jobs
          dates = "*-7";
          options = "--delete-older-than 30d";
          persistent = true;
        };

        optimise = {
          automatic = true;
          # Run on the 21st of the month: offset this a bit from the `gc` job
          # so they don't try to run at the same time
          dates = [ "*-21" ];
        };
      };
    })

    (lib.mkIf cfg.enableSetNixPathAndFlakeRegistry {
      # Use our inputs as defaults for nixpkgs/nixos so everything (like nix-env)
      # moves in lockstep. (Note adding a channel will take precedence over this).
      nix = {
        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
        ];
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
        };
      };
    })
  ];
}
