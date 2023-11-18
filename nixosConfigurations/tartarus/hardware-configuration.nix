# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "cryptd" "amdgpu" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # !!! cryptkey must be done first, and the list seems to be
  # alphabetically sorted, so take care that cryptroot / cryptswap,
  # whatever you name them, come after cryptkey.
  boot.initrd.luks.devices = {
    cryptkey = {
      device = "/dev/disk/by-uuid/e264facc-7943-4fd7-8be7-9fa555664af6";
    };

    cryptroot = {
      allowDiscards = true;
      device = "/dev/disk/by-uuid/50650a6a-003c-4928-82ae-eeeffc3a3fe1";
      keyFile = "/dev/mapper/cryptkey";
      keyFileSize = 8192;
    };

    cryptswap = {
      allowDiscards = true;
      device = "/dev/disk/by-uuid/db266c85-9dce-484a-8b32-00c410b33234";
      keyFile = "/dev/mapper/cryptkey";
      keyFileSize = 8192;
    };
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    cryptsetup close cryptkey
  '';

  fileSystems = {
    "/" = {
      device = "nvme-pool/local/root";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2100-01FF";
      fsType = "vfat";
    };
    "/home/ivan" = {
      device = "nvme-pool/persist/user/ivan";
      fsType = "zfs";
    };
    "/nix" = {
      device = "nvme-pool/local/nix";
      fsType = "zfs";
    };
    "/persist" = {
      device = "nvme-pool/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/scratch" = {
      device = "nvme-pool/local/scratch";
      fsType = "zfs";
    };
    "/var" = {
      device = "nvme-pool/persist/var";
      fsType = "zfs";
    };
  };

  swapDevices = [ ];

  # Bring back previous font look: https://github.com/NixOS/nixpkgs/issues/222805
  fonts.packages = [
    pkgs.xorg.fontmiscmisc
  ];
}
