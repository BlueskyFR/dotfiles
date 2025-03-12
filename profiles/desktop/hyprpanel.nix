{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.hyprpanel = {
    enable = true;

    # Configure and theme almost all options from the GUI.
    # See 'https://hyprpanel.com/configuration/settings.html'.
    # Default: <same as gui>
    settings = {
      # Configure bar layouts for monitors.
      # See 'https://hyprpanel.com/configuration/panel.html'.
      # Default: null
      layout = {
        bar.layouts = {
          "0" = {
            left = ["dashboard" "workspaces"];
            middle = ["media"];
            right = ["volume" "systray" "notifications"];
          };
        };
      };

      bar = {
        launcher.autoDetectIcon = true;
        workspaces.show_icons = true;
      };

      menus = {
        clock = {
          time = {
            military = true;
            hideSeconds = true;
          };
          weather.unit = "metric";
        };

        dashboard = {
          directories.enabled = false;
          stats.enable_gpu = true;
        };
      };

      theme = {
        bar.transparent = true;
        font = {
          name = "CaskaydiaCove NF";
          size = "16px";
        };
      };
    };
  };
}
