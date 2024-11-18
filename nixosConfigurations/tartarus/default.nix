{ pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../users/ivan/default.nix
    ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  # https://nixos.wiki/wiki/NixOS_on_ZFS
  boot.loader.grub.copyKernels = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "elevator=none" ]; # Because ZFS doesn't have the whole disk

  #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  networking = {
    hostName = "tartarus"; # Define your hostname.
    hostId = "feedbeef";
  };

  nix.extraOptions = ''
    secret-key-files = /persist/tartarus-nix-store-signing-secret-key
  '';

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.wlp5s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  programs.dconf.enable = true;
  /* virtualisation.libvirtd = { */
  /*   enable = true; */
  /*   onShutdown = "shutdown"; */
  /* }; */

  location = {
    provider = "manual";
    latitude = 47.6;
    longitude = -122.3;
  };

  services.redshift = {
    enable = true;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "1";
    };
    temperature = {
      day = 4200;
      night = 2900;
    };

    package = pkgs.gammastep;
    executable = "/bin/gammastep";
  };

  # The sway module will unconditionally import wayland-session.nix
  # which defaults to enabling xdg.portal. That in turn adds xdg-desktop-portal-wlr
  # which fails to startup (with pipewire and xdpw failures). Eventually things timeout
  # and the system moves on, but it messes with the rest of my configs starting (like waybar)
  # in a timely manner. Rather than pull a bunch of extra things I don't use, I'd rather turn
  # desktop portals off and revisit it if I ever need them in the future.
  xdg.portal.enable = lib.mkForce false;

  # Desktop/window management
  programs.sway = {
    enable = true;

    wrapperFeatures = {
      base = true; # Setup dbus stuff...
      gtk = true; # Allow GTK apps to run
    };

    # Tweak the extra packages and make sure they're available
    # *just* in case something goes wrong with a user sway config
    extraPackages = with pkgs; [
      alacritty
      #calibre # Build seems broken atm
      dmenu
      swayidle
      swaylock
      wl-clipboard
      xwayland
    ];
  };

  # Enable sound.
  services.pipewire.enable = false; # pipewire is enabled by default for new installs, keep the old behavior here
  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull; # For bluetooth support
  };

  environment.systemPackages = with pkgs; [
    attic-client
    bash
    dnsutils
    element-desktop
    fish
    git
    #handbrake
    htop
    lsof
    pavucontrol
    vim
    vlc
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.ssh = {
    startAgent = false;
    knownHosts = {
      "elysium" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWd8Xzy1H1PwwCYzAypTsnAnybhEXwX0RtWWI8LqcxL";
      };
    };
  };

  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-curses;
    enable = true;
    # enableSSHSupport = true;
  };

  # So smartctl can read the disks
  services.udev.extraRules = ''
    SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="disk"
  '';

  services.prometheus.exporters = {
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

  services.syncoid = {
    enable = true;

    interval = "*:50:00";
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
      "nvme-pool/persist" = {
        recursive = true;
        target = "syncoid-tartarus@elysium:lethe/backups/nvme-pool";
      };
    };

    localSourceAllow = [
      "bookmark"
      "hold"
      "send"
      "release"
    ];

    # NB: remember to run the following on elysium:
    # zfs allow -u syncoid-tartarus \
    #  bookmark,compression,create,destroy,hold,mount,mountpoint,receive,release,rollback \
    # lethe/backups/nvme-pool

    service.serviceConfig = {
      LoadCredential = "sshKey:/persist/syncoid-zfs-send-id_ed25519";
    };
  };
  systemd.timers."syncoid-nvme-pool-persist".timerConfig.Persistent = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
    };
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  services.tailscale.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  programs.command-not-found.enable = false;

  dotfiles._1password.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
