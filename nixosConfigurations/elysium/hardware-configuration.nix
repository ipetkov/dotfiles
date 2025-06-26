{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    extraModulePackages = [ ];

    # !!! cryptkey must be done first, and the list seems to be
    # alphabetically sorted, so take care that cryptroot / cryptswap,
    # whatever you name them, come after cryptkey.
    initrd = {
      availableKernelModules = [
        "ahci"
        "amdgpu"
        "ccp"
        "cryptd"
        "nvme"
        "r8169"
        "sd_mod"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];

      luks.devices = {
        cryptkey = {
          device = "/dev/disk/by-uuid/2896616e-f1d0-48ad-a980-681db105ad1c";
        };

        cryptroot = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/27cbbb09-665b-4a12-bf9e-5f43064839d5";
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
        };

        cryptswap = {
          allowDiscards = true;
          device = "/dev/disk/by-uuid/1eb719ba-5599-4a8c-bc23-c1b7bf43d46b";
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

    kernelModules = [ "kvm-amd" ];

    loader.systemd-boot.enable = true;

    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "lethe" ];
  };

  fileSystems = {
    "/" = {
      device = "acheron/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/87D1-ADFE";
      fsType = "vfat";
      options = [
        "noatime"
        "umask=0077"
      ];
    };

    "/empty/acheron-persist-user" = {
      device = "acheron/persist/user";
      fsType = "zfs";
    };

    "/home/ivan" = {
      device = "acheron/persist/user/ivan";
      fsType = "zfs";
    };

    "/nix" = {
      device = "acheron/local/nix";
      fsType = "zfs";
    };

    "/persist" = {
      device = "acheron/persist/system";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var/lib" = {
      device = "acheron/persist/lib";
      fsType = "zfs";
    };

    "/var/log/journal" = {
      device = "acheron/local/journal";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  swapDevices = [
    {
      device = "/dev/mapper/cryptswap";
    }
  ];
}
