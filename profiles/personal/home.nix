{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  home.packages = with pkgs; [
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 4 silent] discord"
      "[workspace 9 silent] spotify"
    ];
    windowrule = ["workspace 4 silent, match:class discord"];
  };
}
