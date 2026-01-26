{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  imports = [./bluetooth.nix ./hyprlock.nix];

  boot.loader.grub = {
    # Automatically pre-select the last boot item
    default = "saved";
    # Detect other OSs
    useOSProber = true;
  };

  services = {
    displayManager.ly = {
      enable = true;
      x11Support = false;
      # Config file ref: https://is.gd/4M1IwB
      settings = {
        # The active animation
        animation = "colormix";
        # Number of failed attempts before special animation plays
        auth_fails = 3;
        bigclock = "en";
        # blank_box = false;
        # clear_password = true;
        numlock = true;

        # Color mixing animation first color id
        colormix_col1 = "0x00FF5C57";
        # Color mixing animation second color id
        colormix_col2 = "0x00230096";
        # Color mixing animation third color id
        colormix_col3 = "0x20000000";
      };
    };

    xserver = {
      # Configure keymap in X11
      xkb = {
        layout = "fr";
        variant = "";
      };
    };

    # Gaming devices configuration, needed for piper (see home pkgs)
    ratbagd.enable = true;
  };

  programs = {
    # Hyprland
    hyprland = {
      enable = true;
      portalPackage = lib.mkDefault pkgs.xdg-desktop-portal-hyprland; # Just to be exhaustive
      withUWSM = false; # Useless for now, so remove the buggy sddm greeter entry
      # programs.uwsm.enable ?
    };

    light = {
      enable = true;
      # System-level daemon so that brightness controls even work outside
      # of Hyprland like on TTYs
      brightnessKeys = {
        enable = true;
        minBrightness = 1;
      };
    };
  };

  users.users.hugo.extraGroups = ["video"]; # video is for light (screen brightness control)

  # Home-manager introduces its own `config` so we shadow the main scope's
  home-manager.users.hugo = {config, ...}: {
    imports = [
      ./hyprland.nix
      ./rofi.nix

      inputs.dms.homeModules.dank-material-shell
      ./dank-material-shell

      # Ax-Shell
      # inputs.ax-shell.homeManagerModules.default
      # ./ax-shell.nix
    ];

    home.packages = with pkgs; [
      # USB iso/file flasher
      popsicle
      spotify
      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
        commandLineArgs = ["--ozone-platform-hint=auto"];
      })
      discord-krisp
      postman
      pavucontrol
      networkmanagerapplet
      # Gaming devices configuration
      ## Also needs ratbagd (see services)
      piper

      # Vivaldi font fix
      fira

      nautilus
      # Dynamically update Hyprland monitors using a GUI
      nwg-displays
      # Print key names (Wayland equivalent of X11's xev)
      wev
      wl-clipboard-rs
      gparted
      grimblast

      android-tools
    ];

    programs = {
      vscode = {
        enable = true;
        # Use the FHS version of VSCode, which simulates a FHS-compliant chroot env
        # + add required packages for some extensions inside it (see NixOS's VSCode wiki page for more)
        package = pkgs.vscode.fhsWithPackages (pkgs:
          with pkgs; [
            # Classic tools
            git
            rustup
            # Nix
            nixd
            nil
            alejandra
            # Other required
            zlib
            openssl.dev
            pkg-config
          ]);
      };

      alacritty = {
        enable = true;
        settings = {
          # Use our custom Terminal font
          font = let
            mkFont = style: {
              family = "MonoLisaHugoTerm Nerd Font";
              inherit style;
            };
          in {
            size = 16.0; # 20.O

            normal = mkFont "Regular";
            bold = mkFont "Bold";
            italic = mkFont "Italic";
            bold_italic = mkFont "Bold Italic";
          };

          # Snazzy theme
          colors.draw_bold_text_with_bright_colors = true;

          colors.bright = {
            black = "#686868";
            blue = "#57c7ff";
            cyan = "#9aedfe";
            green = "#5af78e";
            magenta = "#ff6ac1";
            red = "#ff5c57";
            white = "#eff0eb";
            yellow = "#f3f99d";
          };

          colors.cursor.cursor = "#97979b";

          colors.normal = {
            black = "#282a36";
            blue = "#57c7ff";
            cyan = "#9aedfe";
            green = "#5af78e";
            magenta = "#ff6ac1";
            red = "#ff5c57";
            white = "#f1f1f0";
            yellow = "#f3f99d";
          };

          colors.primary = {
            background = "#282a36";
            foreground = "#eff0eb";
          };

          colors.selection = {
            background = "#feffff";
            text = "#282a36";
          };
        };
      };

      # Screenshot utility
      hyprshot.enable = true;
    };

    services = {
      flameshot = {
        enable = true;
        settings = {
          General = {
            disabledTrayIcon = true;
            showStartupLaunchMessage = false;
            disabledGrimWarning = true;
            useGrimAdapter = true;
            # Use larger color palette as the default one
            predefinedColorPaletteLarge = true;
          };
          Shortcuts = {
            TYPE_COPY = "Enter";
          };
        };
      };

      # cli tool for controlling media players that implement the MPRIS D-Bus Interface Specification,
      # making it easier to map XF86 keys in Hyprland for instance;
      # Bluetooth headset controls (keys) should be forwarded to the kernel as a key by BlueZ,
      # which Hyprland should be able to catch;
      # so enabling mpris-proxy would be useless and creates a fake player/sink which messes with playerctl.
      # mpris-proxy.enable = false;
      playerctld.enable = true;

      # Clipboard persistence
      ## By default on Wayland, an app "owns" the clipboard data it copies, hence cleared when it's closed
      wl-clip-persist.enable = true;
    };

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';

      # Put VSCode runtime args here instead of customizing pkg (vscode.override)
      # to avoid rebuild
      ".vscode/argv.json".text = ''
        {
          // Allows to disable crash reporting.
          "enable-crash-reporter": false,
          // Fixes the "an OS keyring couldn't be identified for
          // storing the encryption..." error
          "password-store": "gnome-libsecret"
        }
      '';
    };

    gtk = {
      enable = true;
      colorScheme = "dark";
      iconTheme = {
        # package = pkgs.papirus-icon-theme;
        # name = "Papirus";
        package = pkgs.whitesur-icon-theme.override {
          boldPanelIcons = true;
          alternativeIcons = true;
          # themeVariants = ["pink"]; ["all"]
        };
        name = "WhiteSur-dark"; # or e.g. WhiteSur
      };
      theme = {
        package = pkgs.whitesur-gtk-theme.override {
          themeVariants = ["pink"]; # ["all"]
          nautilusStyle = "glassy";
        };
        name = "WhiteSur-Dark-pink"; # or e.g. WhiteSur-Light-solid-pink
        # name = "adw-gtk3";
      };
    };

    home.pointerCursor = {
      # gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
      # Generate HyprCursor config
      hyprcursor.enable = true;
    };

    dconf.settings = {
      # FreeDesktop portal setting requesting dark mode by default.
      ## Chromium seems to expect `/org/freedesktop/portal/desktop/color-scheme=1` but it doesn't work so...
      ## Anyway the following does work for chromium! Test it with `dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"`
      ## with this page for instance (change visible live): https://hugooo.dev/dark-mode.html
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}
