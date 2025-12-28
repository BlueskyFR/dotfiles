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
  home.packages = with pkgs; [
    # oh-my-zsh?
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
    cargo-binstall # Shouldn't be needed - but just in case
    cargo-flamegraph
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

    # System tools
    xdg-utils # Makes url handlers work between apps
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
  ];

  # Make fonts installed through `home.packages` discoverable
  fonts.fontconfig.enable = true;

  # Place config files inside xdg dirs whenever supported instead of e.g. $HOME/.npmrc
  home.preferXdgDirectories = true;

  xdg = {
    enable = true;
    userDirs = {
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

    # Run software without installing it (`, cowsay wow`)
    nix-index-database.comma.enable = true;
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
