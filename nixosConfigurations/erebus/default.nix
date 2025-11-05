{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./persist.nix
    ../../users/ivan/default.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = [ "zfs" ];

  dotfiles = {
    _1password.enable = true;
    nix.distributedBuilds = {
      enable = true;
      sshKey = "/persist/elysium-nixuser-id_ed25519";
    };
  };

  environment = {
    etc = {
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=true
      '';
      "xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=true
      '';
    };
    gnome.excludePackages = [
      pkgs.epiphany
      pkgs.gnome-connections
      pkgs.gnome-tour
      pkgs.orca
      pkgs.seahorse
    ];
    systemPackages = [
      pkgs.bash
      pkgs.dnsutils
      pkgs.fish
      pkgs.git
      pkgs.gnomeExtensions.alternate-menu-for-hplip2
      pkgs.gnomeExtensions.dash-to-dock
      pkgs.gnomeExtensions.gtk4-desktop-icons-ng-ding
      pkgs.gnomeExtensions.tray-icons-reloaded
      pkgs.gnucash
      pkgs.htop
      pkgs.libreoffice
      pkgs.rsync
      pkgs.vim
    ];
  };

  home-manager.users.ivan =
    { ... }:
    {
      imports = [ ../../users/ivan/home.nix ];

      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      dotfiles.taskwarrior.enable = true;
    };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  location = {
    provider = "manual";
    latitude = 47.6;
    longitude = -122.3;
  };

  networking = {
    hostId = "feedb0ba";
    hostName = "erebus";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces = {
      # enp12s0.useDHCP = lib.mkDefault true;
      enp3s0f0.useDHCP = lib.mkDefault true;
      # wlp2s0.useDHCP = lib.mkDefault true;
    };
  };

  programs = {
    command-not-found.enable = false;
    firefox.enable = true;
    thunderbird.enable = true;
  };

  security.rtkit.enable = true;

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Use GNOME
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = false;
      pulse.enable = true;
    };

    printing = {
      enable = true;
      drivers = [
        pkgs.cups-browsed
        pkgs.cups-filters
        pkgs.hplip
      ];
    };

    prometheus.exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [
          "bonding"
          "fibrechannel"
          "infiniband"
          "ipvs"
          "mdadm"
          "nfs"
          "nfsd"
          "nvme"
          "powersupplyclass"
          "rapl"
          "tapestats"
        ];
      };
      smartctl = {
        enable = true;
        port = 9633;
      };
      zfs = {
        enable = true;
        port = 9134;
      };
    };

    # Enable sound with pipewire.
    pulseaudio.enable = false;

    speechd.enable = false;

    syncoid = {
      enable = true;

      interval = "*:30:00";
      commonArgs = [
        "--sshkey"
        "%d/sshKey"
        "--create-bookmark"
        "--no-clone-handling"
        "--no-sync-snap"
        "--use-hold"
        "--skip-parent"
      ];

      commands = {
        "cocytus/persist" = {
          recursive = true;
          target = "syncoid-erebus@elysium:lethe/backups/cocytus";
        };
      };

      localSourceAllow = [
        "bookmark"
        "hold"
        "send"
        "release"
      ];

      # NB: remember to run the following on elysium:
      # zfs allow -u syncoid-erebus \
      #  bookmark,compression,create,destroy,hold,mount,mountpoint,receive,recordsize,release,rollback \
      #  lethe/backups/cocytus
      service = {
        wants = [
          "network-online.target"
          "tailscaled.service"
        ];
        after = [
          "network-online.target"
          "tailscaled.service"
        ];
        serviceConfig = {
          LoadCredential = "sshKey:/persist/syncoid-zfs-send-id_ed25519";
        };
      };
    };

    tailscale.enable = true;

    xserver = {
      enable = true;
      # Use GNOME
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    zfs = {
      autoScrub = {
        enable = true;
        interval = "monthly";
      };
      autoSnapshot.enable = true;
      trim.enable = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  systemd.timers."syncoid-cocytus-persist".timerConfig.Persistent = true;

  time.timeZone = "America/Los_Angeles";

  users.users.ivan.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRVRlSZLcDEdJ13GjfJigN/KT3/Q1odIS4pf+hbmz+Z"
  ];
}
