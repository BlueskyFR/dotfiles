{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  home.packages = with pkgs; [
    teams-for-linux
    remmina
  ];

  wayland.windowManager.hyprland.settings = {
    # exec-once = ["[workspace 4 silent] teams-for-linux"];
    # windowrule = [ "workspace 4 silent, class:teams" ];
  };
}
