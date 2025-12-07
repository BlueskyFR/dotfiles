{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hugo";
  home.homeDirectory = "/home/hugo";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      #(nerdfonts.override {fonts = ["FiraCode"];})
      nerd-fonts.fira-code
      #twemoji-color-font (old one)
      twitter-color-emoji
      # Custom fonts
      # stdenv.mkDerivation
      # {
      #   name = "Operator Mono SSm Lig Book";
      #   version = "1.0";
      #   src = self;

      #   installPhase = ''
      #     dest="$out/share/fonts/opentype/Operator Mono SSm Lig Book"
      #     mkdir -p $dest
      #     cp -r custom-fonts/* $dest
      #   '';
      # }

      # oh-my-zsh?
      # firacode ttf nerd
      # my custom font here
      # starship
      # zsh-syntax-highlighting
      # zsh-autosuggestions
      # Alacritty snazzy
      # WORK ONLY: teams, slack, remmina (+ freerdp for rdp support?), minicom

      # Dev
      gh
      deno
      ## Rust
      rustup
      gcc # Needed for rustup
      bacon

      # Cli tools
      zip
      unzip

      # rofi + rofi themes (gh) + rofimoji
      trashy # trash-cli alternative, usage -> alias rm="trashy"
      nmap
      manix # Nix/HM cli doc searcher
      nix-output-monitor # Fancy dependency graph for `nix build`
      tldr

      pcmanfm
      # Dynamically update Hyprland monitors using a GUI
      nwg-displays

      # System tools
      xdg-utils # Makes url handlers work between apps
      gparted
      # GUI agent for polkit interactive auth
      polkit_gnome
      grimblast
      nix-inspect
      openssl
      # git secret management
      # transcrypt

      # piper?

      # Nix language server
      nil
      # Nix language formatter
      alejandra

      # Custom scripts
      # fup-repl

      # Extremely important
      sl
      cmatrix
      asciiquarium
      neofetch
      ipfetch
      countryfetch

      (writeShellScriptBin "upgrade-firmware" ''
        sudo fwupdmgr get-devices
        echo Waiting 10 sec...
        sleep 10
        sudo fwupdmgr refresh --force
        sudo fwupdmgr get-updates
        sudo fwupdmgr update
      '')
    ]
    ++ (let
      script = {
        updateFlakeInputs ? false,
        fancyOutput ? false,
      }: ''
        sudo true
        ${
          if updateFlakeInputs
          then "nix flake update --flake ${flakeDir}"
          else ""
        }
        sudo nixos-rebuild switch --flake ${flakeDir}${
          if fancyOutput
          then " |& ${nix-output-monitor}/bin/nom"
          else ""
        }'';
    in [
      # Rebuild/sync system
      (writeShellScriptBin "s" (script {}))
      # Update flake inputs + rebuild system
      (writeShellScriptBin "us" (script {updateFlakeInputs = true;}))
      # Rebuild/sync system (fancy)
      (writeShellScriptBin "sf" (script {fancyOutput = true;}))
      # Update flake inputs + rebuild system (fancy)
      (writeShellScriptBin "usf" (script {
        updateFlakeInputs = true;
        fancyOutput = true;
      }))
    ]);

  # Autostart the gnome polkit agent
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;
    publicShare = null;
    templates = null;
    documents = "${config.home.homeDirectory}/docs";
    download = "${config.home.homeDirectory}/dl";
    pictures = "${config.home.homeDirectory}/pics";
    videos = "${config.home.homeDirectory}/vids";
    music = "${config.home.homeDirectory}/music";
  };

  programs = {
    btop = {
      enable = true;
      settings = {
        color_theme = "dracula";
        update_ms = 100;
      };
    };

    bat.enable = true;

    lsd = {
      enable = true;
      # We already define our own ls aliases, so no need to declare them a second time
      enableZshIntegration = false;
    };
    bottom.enable = true;

    git = {
      enable = true;
      settings = {
        user = {
          name = "Hugo Cartigny (BlueskyFR)";
          email = "hugo.cartigny@gmail.com";
        };
        color.ui = "auto";
        pull.rebase = true;
        pull.autoStash = true;
        push.autoSetupRemote = true;
      };
    };

    poetry = {
      enable = true;
      settings = {
        # Create a venv if it doesn't exist, so do not use an existing and/or
        # system environment
        virtualenvs.create = true;
        # Do not use $HOME/.cache/pypoetry but create venvs in project dirs
        virtualenvs.in-project = true;
      };
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hugo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "code --wait";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
