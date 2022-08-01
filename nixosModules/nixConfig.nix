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
        package = pkgs.nixFlakes;
        extraOptions = ''
          experimental-features = nix-command flakes
          keep-outputs = true
          keep-derivations = true
        '';
        useSandbox = true;

        binaryCaches = [
          "https://crane.cachix.org"
          "https://ipetkov.cachix.org"
        ];
        binaryCachePublicKeys = [
          "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
          "ipetkov.cachix.org-1:xK9taxnomX0ZVyDmobpZB5AQvuZ+L3q4u7IlRvEtomg="
        ];

        gc = {
          automatic = true;
          dates = "monthly";
          options = "--delete-older-than 30d";
          persistent = true;
        };

        optimise.dates = [ "monthly" ];
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
