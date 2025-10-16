{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  boot.loader.grub = {
    # Automatically pre-select the last boot item
    default = "saved";
    # Detect other OSs
    useOSProber = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # Also enable a bluetooth device pairing GUI
  services.blueman.enable = true;

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

  # Home-manager introduces its own `config` so we shadow the main scope one
  home-manager.users.hugo = {config, ...}: {
    imports = [./hyprland.nix ./rofi.nix ./hyprpanel.nix];

    home.packages = with pkgs; [
      # USB iso/file flasher
      popsicle
      spotify
      (vivaldi.override {commandLineArgs = ["--ozone-platform-hint=auto"];})
      discord-krisp
      postman

      # Vivaldi font fix
      fira
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
          font.size = 16.0; # 20.O

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
      # theme.name = "adw-gtk3";
      # iconTheme.name = "GruvboxPlus";
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
