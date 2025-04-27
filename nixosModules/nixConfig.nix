{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.dotfiles.nix;
  chosenNixpkgs = config.nixpkgs.flake.source;
in
{
  # The nixpkgs source is kinda large (87MB at this time, but constantly growing)
  # so allow machines (i.e. non-desktops) to opt out of adding it to the NIX_PATH/flake registry
  # to avoid having to copy it over with all deployments
  options.dotfiles.nix = {
    enableSetNixPathAndFlakeRegistry = mkOption {
      type = lib.types.bool;
      default = true;
      example = true;
      description = "Whether to add nixpkgs to nixPath and flake registry";
    };

    distributedBuilds = mkOption {
      default = { };
      type = types.submodule {
        options = {
          enable = mkEnableOption "distributed builds";
          sshKey = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      };
    };
  };

  config = lib.mkMerge [
    ({
      nix = {
        package = pkgs.lixPackageSets.stable.lix;
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
            "elysium.ipetkov.dev-1:H0okpsNoJPtsge8uMtBiN6tLavSyi+l3ziMTA31CRfc="
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

      # This pulls in vanilla nix, plus I don't use it anyway
      system.tools.nixos-option.enable = false;
    })

    (lib.mkIf cfg.enableSetNixPathAndFlakeRegistry {
      # Use our inputs as defaults for nixpkgs/nixos so everything (like nix-env)
      # moves in lockstep. (Note adding a channel will take precedence over this).
      nix = {
        nixPath = [
          "nixpkgs=${chosenNixpkgs}"
        ];
        registry = {
          nixpkgs.flake.outPath = chosenNixpkgs;
        };
      };
    })

    (lib.mkIf cfg.distributedBuilds.enable {
      nix = {
        buildMachines = [{
          inherit (cfg.distributedBuilds) sshKey;

          hostName = "elysium";
          maxJobs = 4;
          protocol = "ssh-ng";
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9XZDhYenkxSDFQd3dDWXpBeXBUc25BbnliaEVYd1gwUnRXV0k4THFjeEwgcm9vdEBlbHlzaXVtCg==";
          speedFactor = 1;
          sshUser = "nixuser";
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        }];
        distributedBuilds = true;
        settings.builders-use-substitutes = true;
      };
    })
  ];
}
