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
        # DP-3 = 4K, DP-2 = 2K
        # "DP-3, highrr, 0x0, auto, vrr, 1" # Variable refresh rate, 1 = on
        ##"DP-2, highres, 0x0, auto"
        # (1440 / 1.25) - 1080 = -72 (compute the delta on the scaled height or width)
        ##"DP-3, highres, 2560x-72., 1.5, vrr, 0" # Variable refresh rate, 1 = on
      ];

      # Override nwg-displays' settings for this particular screen to enable HDR support
      monitorv2 = lib.mkForce [
        {
          # DP-3,3840x2160@239.99,2560x0,1.5,bitdepth,10,supports_wide_color,1,supports_hdr,1,sdr_min_luminance,0.005,sdr_max_luminance,200
          output = "DP-3";
          mode = "3840x2160@239.99";
          # position = "2560x0";
          position = "2048x0";
          scale = 1.5;
          bitdepth = 10;
          supports_wide_color = true;
          supports_hdr = true;
          sdr_min_luminance = 0.005;
          sdr_max_luminance = 200;
          min_luminance = 0; # Monitor’s minimum luminance	float
          max_luminance = 200; # Monitor’s maximum possible luminance	int
          # max_avg_luminance = XX  # Monitor’s maximum luminance on average for a typical frame	int
        }
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

  # G213 keyboard leds
  services.udev = {
    packages = [pkgs.g810-led];
    # Horizontal RGB wave effect, length 0xAA * 256ms = 43sec
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", RUN+="${pkgs.g810-led}/bin/g810-led -fx hwave keys aa"
    '';
  };
}
