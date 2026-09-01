{
  inputs,
  pkgs,
  lib,
  self,
  config,
  flakeDir,
  ...
}: {
  imports = [];

  # Allow user processes to aquire realtime scheduling priority on demand (e.g. used by PipeWire)
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  home-manager.users.hugo = {
    # Add our config at the user level (in `$XDG_CONFIG_HOME/pipewire/pipewire.conf.d/`)
    xdg.configFile = {
      "pipewire/pipewire.conf.d/dolby-atmos-surround.conf" = {
        source = ./dolby-atmos-surround.conf;
        # Trigger the HM module PipeWire service reload
        # (from https://github.com/nix-community/home-manager/blob/99c9ec63390f1d8c14d95d9e8b17cc29cfbd4e11/modules/services/pipewire.nix#L375)
        onChange = ''
          if [[ ! -v PIPEWIRE_RELOAD ]]; then
            PIPEWIRE_RELOAD=1
          fi
        '';
      };
    };

    services.pipewire = {
      # Just enable the module so that it can reload our changes
      enable = true;
      # The below line expects some Nix-formatted json, which makes it annoying to copy-paste
      # existing online configs, so we paste raw files using `xdg.configFile above`.
      # configs = {
      #   "dolby-atmos-surround" = {};
      # };
    };

    home.packages = with pkgs; [
    ];
  };
}
