{ config, pkgs, ... }:

{
  imports = [
  ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages; # Use LTS kernel
  boot.kernelParams = [
    # Needed for the virtual console to work on the RPi 3, as the default of 16M
    # doesn't seem to be enough. If X.org behaves weirdly (I only saw the cursor)
    # then try increasing this to 256M.
    "cma=32M"

    # Enable serial console
    "console=ttyS1,115200n8"
  ];

  boot.enableContainers = false;
  boot.tmp.cleanOnBoot = true;

  # Trim fat
  boot.bcache.enable = false;
  boot.swraid.enable = false;

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024; # MB
    }
  ];

  # Allows "wheel" users to not need to type a password to get sudo.
  # Useful for doing remote deployments without having an ssh key for root.
  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable = false; # Unused, trim some fat

  # Copying nixpkgs-source causes a big I/O penalty on SD card writes, so skip it
  dotfiles = {
    nix = {
      distributedBuilds.enable = true;
      enableSetNixPathAndFlakeRegistry = false;
    };
    services.pihole.enable = true;
  };

  nix = {
    optimise.automatic = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      # Needed to get wifi drivers working, may need to revisit/remove once drivers are upstreamed?
      firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
        version = "2020-12-18";
        src = pkgs.fetchgit {
          url =
            "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "b79d2396bc630bfd9b4058459d3e82d7c3428599";
          sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
        };
        outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
      });
    })
  ];

  networking = {
    hostName = "rpi";
    hostId = "cafeb0ba";
    wireless.enable = true; # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlan0.useDHCP = true;
  };

  environment.systemPackages = with pkgs; [
    htop
    vim
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  users.users.ivan = {
    isNormalUser = true;
    home = "/home/ivan";
    extraGroups = [
      "wheel" # Enable sudo
      "disk"
      "systemd-journal"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRVRlSZLcDEdJ13GjfJigN/KT3/Q1odIS4pf+hbmz+Z"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKGnvJIfS1FFpLzfa+OlKU/YEC1p29HPzSKCNTsIUMZ"
    ];
  };

  # Stop additional documentation, etc. from being generated
  documentation.enable = false; # Man cache takes forever to build
  documentation.man.enable = false; # Man cache takes forever to build
  documentation.doc.enable = false;
  documentation.info.enable = false;
  documentation.nixos.enable = false;

  # Locales
  time.timeZone = "America/Los_Angeles";
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];
  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    command-not-found.enable = false;
    nano.enable = false;
  };

  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "monthly";
  };
  systemd.timers.docker-prune.timerConfig.Persistent = true;

  services = {
    openssh.enable = true;
    tailscale.enable = true;
    udisks2.enable = false; # Unused, trim some fat

    # Limit the journal size to X MB or last Y days of logs
    journald.extraConfig = ''
      SystemMaxUse=1536M
      MaxFileSec=60day
    '';
  };

  # Trim more fat
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
