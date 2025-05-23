{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./persist.nix
    inputs.nixos-pibox.nixosModules.default
  ];

  nixpkgs = {
    overlays = [
      inputs.nixos-pibox.overlays.default
      (final: prev: {
        # https://github.com/NixOS/nixpkgs/pull/239658#issuecomment-1622748163
        compressFirmwareXz = firmware: prev.compressFirmwareXz (builtins.removeAttrs firmware [ "meta" ]);
      })
    ];
  };

  networking = {
    hostName = "asphodel";
    hostId = "feeddead";

    networkmanager.enable = true;

    useDHCP = false;
    interfaces = {
      eth0.useDHCP = true;
      wlan0.useDHCP = true;
    };
  };

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    bash
    dnsutils
    fish
    git
    htop
    vim
  ];

  dotfiles = {
    nix.distributedBuilds.enable = true;
    zfs-send = {
      enable = true;
      rootPool = "phlegethon";
    };
  };

  services = {
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    openssh.enable = true;

    piboxPwmFan.enable = true;
    # Broken on Linux 6.1 the sitronix driver doesn't seem to work
    #piboxFramebuffer.enable = true;

    tailscale.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
        interval = "monthly";
      };
      autoSnapshot.enable = true;
      trim.enable = true;
    };
  };

  users.mutableUsers = false;
  users.users.ivan = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/ivan";
    extraGroups = [
      "wheel" # Enable sudo
      "disk"
      "systemd-journal"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRVRlSZLcDEdJ13GjfJigN/KT3/Q1odIS4pf+hbmz+Z"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  programs.command-not-found.enable = false;

  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;
}
