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

  # wow.hyprlandGitVersion.enable = true;
  services.flatpak.enable = true;

  # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;

  # NFS mount
  fileSystems."/tv" = {
    device = "yurt.wow:/tv";
    fsType = "nfs";
    options = [
      # Dynamic automount on access
      "x-systemd.automount"
      # Auto-unmount timeout (30 min)
      "x-systemd.idle-timeout=1800"
      # Prevents mounting at boot (required for automount)
      "noauto"
    ];
  };

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
      ## Check at https://testufo.com/hdr
      # monitorv2 = lib.mkForce [
      #   {
      #     # DP-3,3840x2160@239.99,2560x0,1.5,bitdepth,10,supports_wide_color,1,supports_hdr,1,sdr_min_luminance,0.005,sdr_max_luminance,200
      #     output = "DP-2";
      #     mode = "3840x2160@239.99";
      #     # position = "2560x0";
      #     position = "2048x0";
      #     scale = 1.5;
      #     bitdepth = 10;
      #     supports_wide_color = 1;
      #     supports_hdr = 1;
      #     sdr_min_luminance = 0.005;
      #     sdr_max_luminance = 215;
      #     cm = "hdr";
      #     vrr = 0;
      #     #min_luminance = 0; # Monitor’s minimum luminance	float
      #     #max_luminance = 200; # Monitor’s maximum possible luminance	int
      #     # max_avg_luminance = XX  # Monitor’s maximum luminance on average for a typical frame int
      #   }
      # ];
      # Avoid black flashes (https://wiki.hypr.land/0.54.0/Configuring/Variables/#quirks)
      # quirks = {
      #   prefer_hdr = 1;
      # };

      #misc.vfr = true;
      misc = {
        # Hides a window when it spawns a subprocess/child
        enable_swallow = true;
        # Matches classes
        swallow_regex = ["^Alacritty$"];
        # Matches titles to ignore
        swallow_exception_regex = [".*wev.*"];
      };

      render = {
        cm_enabled = true;
        cm_auto_hdr = 1;
      };
    };
  };

  # G213 keyboard leds
  services.udev = {
    packages = [pkgs.g810-led];
    # Horizontal RGB wave effect, length 0xAA * 256ms = 43sec
    # Extra udev rule in case of keyboard plug/unplug
    # idVendor + idProduct fetched with `cyme` (lsusb)
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c336", RUN+="${pkgs.g810-led}/bin/g810-led -fx hwave keys aa"

      # STM32 DFU (Flysky EL18 STM32 DFU mode access from chromium-based browsers/WebUSB)
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="users", TAG+="uaccess"
    '';
  };
}
