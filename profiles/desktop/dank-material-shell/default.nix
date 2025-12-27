{
  config,
  pkgs,
  lib,
  ...
}: {
  # Also provides a GUI Polkit agent through Quickshell
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # enableSystemMonitoring = true;
    # enableClipboard = true;
    # enableVPN = true;
    # enableBrightnessControl = true;
    # enableColorPicker = true;
    # enableDynamicTheming = true;
    # enableAudioWavelength = true;
    # enableCalendarEvents = true;
    # enableSystemSound = true;

    # Config applied if no other config exists already
    # default.settings = lib.importJSON ./settings.json;
  };

  # Overwrite DMS' config with ours every time instead of on first install only
  xdg.configFile."DankMaterialShell/settings.json" = {
    force = true;
    source = ./settings.json;
  };
}
