{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    extraModulePackages = [ ];

    # !!! cryptkey must be done first, and the list seems to be
    # alphabetically sorted, so take care that cryptroot / cryptswap,
    # whatever you name them, come after cryptkey.
    initrd = {
      luks.devices = {
        cryptkey = {
          device = "/dev/disk/by-uuid/65c4794c-dbbd-47d4-9611-716c68fab36a";
        };

        cryptroot = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/396901c7-225a-4c50-b723-b7e6f2a7f772";
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
        };

        cryptswap = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/b6e946d7-27b9-48f6-99ff-6ab9d355b644";
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
        };
      };

      postDeviceCommands = lib.mkAfter ''
        cryptsetup close cryptkey
        zfs rollback -r phlegethon/local/root@blank && echo blanked out root
      '';
    };

    loader = {
      efi.canTouchEfiVariables = true;
      generic-extlinux-compatible.enable = false;
      systemd-boot.enable = true;
      timeout = 10; # seconds
    };

    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
    ];

    supportedFilesystems = [ "zfs" ];
  };

  fileSystems = {
    "/" = {
      device = "phlegethon/local/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0F92-BECC";
      fsType = "vfat";
    };

    "/home/ivan" = {
      device = "phlegethon/persist/user/ivan";
      fsType = "zfs";
    };

    "/nix" = {
      device = "phlegethon/local/nix";
      fsType = "zfs";
    };

    "/persist" = {
      device = "phlegethon/persist/system";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var/lib" = {
      device = "phlegethon/persist/lib";
      fsType = "zfs";
    };

    "/var/log/journal" = {
      device = "phlegethon/persist/journal";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  swapDevices = [
    {
      device = "/dev/mapper/cryptswap";
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}