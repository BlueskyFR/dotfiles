# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  # Flake-parts args, with system pre-selected
  inputs',
  self',
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  # wow.hyprlandGitVersion.enable = true;
  services.flatpak.enable = true;

  # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;

  # Disable remote builds for this host since it has a good conection/compute power/storage
  remote-builds.enable = true;

  hyprland-variables = {
    monitors = [
      {
        output = "desc:Dell Inc. AW3225QF JL89YZ3";
        mode = "3840x2160@239.99";
        position = "2048x0";
        scale = 1.5;
        bitdepth = 10;
        cm = "hdr";
        supports_hdr = 1;
        supports_wide_color = 1;
        vrr = 3; # 2 = fullscreen only; 3 = when fullscreen or game
        sdr_max_luminance = 300;
        sdr_min_luminance = 0.005;
        # Tweaks
        min_luminance = 0.03;
        max_luminance = 1000;
        max_avg_luminance = 500;
      }
      {
        output = "desc:HP Inc. HP 27xq CNK93737GG";
        mode = "2560x1440@143.86";
        position = "0x90";
        scale = 1.25;
        vrr = 0;
      }
    ];
  };

  # NFS mount
  fileSystems = {
    "/tv" = {
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
    "/backup" = {
      device = "yurt.wow:/backup";
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
  };

  home-manager.users.hugo = {
    home.packages = with pkgs; [
      # Video editing, only needed on this host
      gyroflow

      # davinci-resolve-studio
      # inputs'.ableton-linux.packages.default

      # (callPackage ./davinci-resolve.nix {studioVariant = true;})
    ];
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
      # Betaflight STM32
      # ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{iManufacturer}=="Betaflight", MODE="0664", GROUP="users", TAG+="uaccess"
      # DFU (Internal bootloader for STM32 and AT32 MCUs)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", MODE="0664", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", TAG+="uaccess"
      # Add more & check with `lsusb` and `lsusb -v | less`
    '';
  };

  networking.firewall.allowedUDPPortRanges = [
    # WebRTC
    {
      from = 10000;
      to = 20000;
    }
  ];
}
