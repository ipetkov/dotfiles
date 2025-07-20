{ pkgs, ... }:

# https://github.com/quickemu-project/quickemu/issues/468#issuecomment-3122492797
{
  environment.systemPackages = [
    (pkgs.quickemu.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./quickemu.patch
      ];
    }))
  ];

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="12a8", GROUP="users", MODE="0660"
  '';

  virtualisation.spiceUSBRedirection.enable = true;
}
