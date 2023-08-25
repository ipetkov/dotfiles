{ config, lib, pkgs, ... }:

let
  inherit (lib) escapeShellArg;
  cfg = config.dotfiles.zfs-send;
  hasZfs = builtins.any (e: e == "zfs") config.boot.initrd.supportedFilesystems;
in
{
  options.dotfiles.zfs-send = {
    enable = lib.mkEnableOption "zfs-send";
    rootPool = lib.mkOption {
      type = lib.types.str;
      example = "tank";
      description = ''
        the root pool of the host. zfs send permissions will be delegated to $POOL/persist
      '';
    };
  };

  config = lib.mkMerge [
    ({
      # NB: the syncoid user is _always_ present to avoid a recycled UID
      # suddenly gaining the existing permissions when we cannot remove them
      users = {
        groups.syncoid = { };
        users.syncoid = {
          group = config.users.groups.syncoid.name;
          isSystemUser = true;
        };
      };
    })

    # When disabled, strip any previous permissions we may have granted
    (lib.mkIf (!cfg.enable) {
      users.users.syncoid.useDefaultShell = false; # Do NOT permit login
      #system.activationScripts.zfs-unallow-syncoid = {
      #  deps = [ "users" ];
      #  text = lib.optionalString hasZfs ''
      #    echo 'removing delegated zfs permissions for sending snapshots'
      #    /run/booted-system/sw/bin/zfs list -H -o name -d 0 | \
      #      xargs -n1 /run/booted-system/sw/bin/zfs unallow -r -u ${escapeShellArg config.users.users.syncoid.name}
      #  '';
      #};
    })

    (lib.mkIf cfg.enable {
      # Packages used by syncoid, make them available on the whole system
      environment.systemPackages = with pkgs; [
        procps
        pv
        mbuffer
        lzop
      ];

      users.users.syncoid.useDefaultShell = true; # Do permit login

      system.activationScripts.zfs-allow-syncoid = {
        deps = [ "users" ];
        text = ''
          echo 'delegating zfs permissions for sending snapshots'
          /run/booted-system/sw/bin/zfs allow \
            -u ${escapeShellArg config.users.users.syncoid.name} \
            bookmark,hold,send,release \
            ${escapeShellArg cfg.rootPool}/persist
        '';
      };
    })
  ];
}
