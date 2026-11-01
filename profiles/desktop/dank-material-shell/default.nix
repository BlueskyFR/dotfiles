{
  config,
  pkgs,
  lib,
  ...
}: {
  # Also provides a GUI Polkit agent through Quickshell
  programs.dux-shell = {
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

  # Home-manager options
  home-manager.users.hugo = {
    # Overwrite DMS' config with ours every time instead of on first install only
    xdg.configFile."DankMaterialShell/settings.json" = {
      force = true;
      source = ./settings.json;
    };

    home.packages = with pkgs; [
      # User-space application to modify the Intel Extensible Firmware Interface (EFI) Boot Manager;
      # allows rebooting to Windows automatically by setting the firmware's one-time BootNext entry.
      efibootmgr
    ];
  };
}
