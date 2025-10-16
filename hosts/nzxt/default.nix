# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
} @ inputs: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  # Force the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # wow.hyprlandGitVersion.enable = true;

  home-manager.users.hugo = {
    wayland.windowManager.hyprland.settings = {
      # Monitors configuration
      # monitor = name, resolution, position, scale
      # Position: X is normal but Y is reversed
      # Also check `hyprctl monitors all`
      monitor = lib.mkForce [
        # "DP-3, highrr, 0x0, auto, vrr, 1" # Variable refresh rate, 1 = on
        "DP-2, highres, 0x0, auto"
        # (1440 / 1.25) - 1080 = -72 (compute the delta on the scaled height or width)
        "DP-3, highrr, 1920x-72, 1.25, vrr, 0" # Variable refresh rate, 1 = on
      ];

      #misc.vfr = true;
      misc = {
        # Hides a window when it spawns a subprocess/child
        enable_swallow = true;
        # Matches classes
        swallow_regex = ["^Alacritty$"];
        # Matches titles to ignore
        swallow_exception_regex = [".*wev.*"];
      };
    };
  };
}
