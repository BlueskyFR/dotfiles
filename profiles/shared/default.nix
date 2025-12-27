{
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  imports = [./beta.nix];

  # Home manager global config
  home-manager = {
    # Use global nixpkgs
    useGlobalPkgs = true;
    # Allow per-user packages
    useUserPackages = true;
    users.hugo.imports = [./home.nix ./aliases.nix ./zsh.nix];
    extraSpecialArgs = {inherit flakeDir;};
  };

  # Use the latest stable Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader = {
    grub = {
      # Use Grub instead of the (simple and limited) systemd-boot default
      enable = true;
      # Enable (U)EFI support
      efiSupport = true;
      # For old BIOS-based systems, Grub had to write a tiny bit of machine code
      # at the start of the disk; EFI now mandates a partition (/boot) on the
      # main disk, so we use the special "nodev" value preventing that behavior.
      # More info: https://is.gd/fZ6Gks
      device = "nodev";

      # Custom theme
      theme = pkgs.bsol-grub2-theme;
    };
    efi.canTouchEfiVariables = true;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      # Replaces files having identical contents with hard links to save disk space,
      # after each build
      auto-optimise-store = false;
    };

    # Automatic store optimisation, not after each build but from a systemd timer
    optimise = {
      automatic = true;
      dates = ["monthly"];
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      # Cannot specify something like [7d or 5 last ones, whichever is more]
      # Improvement: https://nixos.wiki/wiki/NixOS_Generations_Trimmer
      options = "--delete-older-than 14d";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = let
    formatLocale = "fr_FR.UTF-8";
  in {
    LC_ADDRESS = formatLocale;
    LC_IDENTIFICATION = formatLocale;
    LC_MEASUREMENT = formatLocale;
    LC_MONETARY = formatLocale;
    LC_NAME = formatLocale;
    LC_NUMERIC = formatLocale;
    LC_PAPER = formatLocale;
    LC_TELEPHONE = formatLocale;
    LC_TIME = formatLocale;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.hugo = {
      isNormalUser = true;
      description = "Hugo";
      extraGroups = ["networkmanager" "wheel"];
      # packages = with pkgs; [];
    };

    defaultUserShell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    vim
    curl
    wget
    tree
    file

    docker-compose
    passt

    # Network tools
    tcpdump
    ipcalc

    # Hardware listing utils
    usbutils # Provides lsusb
    cyme # Better lsusb
  ];

  programs = {
    # Zsh, already configured in home-manager but required here so that the right files are sourced
    zsh.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = {
    # Support for VSCode auth token
    gnome.gnome-keyring.enable = true;

    # Automatic drive mounting
    devmon.enable = true;
    # Userspace virtual filesystem, abstracts ssh/ftp/remote filesystems
    # for tools like pcmanfm, browsers...
    gvfs.enable = true;
    # DBus service that allows applications to query & manipulate storage devices
    udisks2 = {
      enable = true;
      # Mounts drives on /media instead of the default, ACL-controlled
      # /run/media/$USER (nicer to type!) and cleans stale mountpoints at boot
      mountOnMedia = true;
    };
    # DBus service that provides power management support to applications
    upower.enable = true;
    # Firmware update utility/DBus service
    fwupd.enable = true;

    # Support 24 bit colors instead of 256 by replacing Getty with Kmscon for TTYs
    kmscon = {
      enable = true;
      hwRender = true;
      useXkbConfig = true;
    };
  };

  security.sudo.extraConfig = ''
    # No password prompt timeout
    Defaults passwd_timeout=0
    # Set password timeout from 5 to 10 minutes
    Defaults timestamp_timeout=10
  '';

  # Podman/containers
  virtualisation = {
    ## Enable common container config files in /etc/containers
    containers = {
      enable = true;
      containersConf.settings = {
        network = {
          default_subnet = "172.16.0.0/16";
          default_subnet_pools = [
            {
              base = "172.17.0.0/16";
              size = 24;
            }
            {
              base = "172.18.0.0/15";
              size = 24;
            }
            {
              base = "172.20.0.0/14";
              size = 24;
            }
            {
              base = "172.24.0.0/14";
              size = 24;
            }
            {
              base = "172.28.0.0/14";
              size = 24;
            }
          ];
        };
      };
    };

    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other
      defaultNetwork.settings.dns_enabled = true;

      autoPrune = {
        enable = true;
        dates = "monthly";
      };
    };
  };

  # Podman containers minimum port
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Configure console keymap
  console.keyMap = lib.mkDefault "fr";

  environment.sessionVariables = {
    # Make electron apps use Wayland Ozone (still in dev so disabled by default)
    # Ozone is an abstractions working on many targets such as X11 or Wayland
    NIXOS_OZONE_WL = "1";
  };

  # Enable completions for system packages
  environment.pathsToLink = ["/share/zsh"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
