{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../nixosModules/_1password.nix
      ../../nixosModules/tailscale.nix
      ../../users/ivan/default.nix
    ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  # https://nixos.wiki/wiki/NixOS_on_ZFS
  boot.loader.grub.copyKernels = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "elevator=none" ]; # Because ZFS doesn't have the whole disk

  # Use the latest kernel which is compatible with stable ZFS
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  networking = {
    hostName = "tartarus"; # Define your hostname.
    hostId = "feedbeef";
  };

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
      dmenu
      swayidle
      swaylock
      wl-clipboard
      xwayland
    ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull; # For bluetooth support
  };

  environment.systemPackages = with pkgs; [
    bash
    dnsutils
    fish
    gitMinimal
    htop
    pavucontrol
    vim
    /* virt-manager */
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.ssh.startAgent = true;
  programs.gnupg.agent = {
    pinentryFlavor = "curses";
    enable = true;
    # enableSSHSupport = true;
  };

  # List services that you want to enable:

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
}
