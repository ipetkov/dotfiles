{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./persist.nix
  ];

  networking = {
    hostName = "elysium";
    hostId = "deadcafe";

    networkmanager.enable = true;

    useDHCP = false;
    interfaces = {
      eno1.useDHCP = true;
      wlp8s0.useDHCP = true;
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
    rsync
    vim
  ];

  services = {
    openssh.enable = true;

    tailscale.enable = true;
    zfs = {
      autoScrub = {
        enable = true;
        interval = "Mon *-*-* 03:00:00";
      };
      autoSnapshot.enable = true;
      trim.enable = true;
    };
  };

  users.mutableUsers = false;
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

  nix = {
    # Users allowd to import NARs into the nix store without signatures
    # (i.e. allows us to run `nixos-rebuild switch --build-host localhost --target-host ...`
    # from another machine).
    settings.trusted-users = [
      "ivan"
    ];
  };

  security.sudo.execWheelOnly = true;
  security.sudo.wheelNeedsPassword = false;
}
