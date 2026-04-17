{ ... }:

{
  boot.initrd.systemd.services = {
    cryptkey-close = {
      script = ''
        set -x
        systemd-cryptsetup detach cryptkey || echo cannot detach cryptkey
      '';
      serviceConfig.Type = "oneshot";
      wantedBy = [ "initrd-switch-root.target" ];
    };
  };
}
