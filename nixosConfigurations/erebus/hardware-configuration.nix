{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "ohci_pci"
        "ehci_pci"
        "firewire_ohci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
        "tg3"
      ];
      kernelModules = [ ];

      # !!! cryptkey must be done first, and the list seems to be
      # alphabetically sorted, so take care that cryptroot / cryptswap,
      # whatever you name them, come after cryptkey.
      luks.devices = {
        cryptkey = {
          device = "/dev/disk/by-uuid/73b9226b-dbb1-4b9c-84c0-80e061180af8";
        };

        cryptroot = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/0f883b04-6875-4503-9974-f49ac1ed9d0c";
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
        };

        cryptswap = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/eafc2a4d-e784-4a85-901d-c429664ad797";
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
        };
      };

      postDeviceCommands = lib.mkAfter ''
        cryptsetup close cryptkey
      '';

      # Support remote unlock. Run `cryptsetup-askpass` to unlock
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = config.users.users.ivan.openssh.authorizedKeys.keys;
          hostKeys = [
            # Note this file lives on the host itself, and isn't passed in by the deployer
            "/persist/etc/ssh/initrd_ssh_host_ed25519_key"
          ];
        };
      };
    };
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    # https://www.cve.org/CVERecord?id=CVE-2019-9502
    # https://www.cve.org/CVERecord?id=CVE-2019-9501
    # extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  };

  # dotfiles.unfree.packageNames = [ "broadcom-sta" ];

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "cocytus/local/root";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8399-4D8C";
      fsType = "vfat";
      options = [
        "noatime"
        "umask=0077"
      ];
    };
    "/empty/user" = {
      device = "cocytus/persist/user";
      fsType = "zfs";
    };
    "/home/ivan" = {
      device = "cocytus/persist/user/ivan";
      fsType = "zfs";
    };
    "/nix" = {
      device = "cocytus/local/nix";
      fsType = "zfs";
    };
    "/persist" = {
      device = "cocytus/persist/system";
      fsType = "zfs";
      neededForBoot = true;
    };
    "/var/lib" = {
      device = "cocytus/persist/lib";
      fsType = "zfs";
    };
    "/var/log/journal" = {
      device = "cocytus/local/journal";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  swapDevices = [
    {
      device = "/dev/mapper/cryptswap";
    }
  ];

  # Bring back previous font look: https://github.com/NixOS/nixpkgs/issues/222805
  fonts.packages = [
    pkgs.font-misc-misc
  ];
}
