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
  ];

  home-manager.users.hugo = {
    wayland.windowManager.hyprland.settings = {
      # monitor = lib.mkForce [
      #   "eDP-1, highres, auto, 1.25"
      #   ", preferred, auto, auto"
      #   ", preferred, auto, auto"
      #   ", preferred, auto, auto"
      # ];
      monitor = lib.mkForce [];
      # monitorv2 = lib.mkForce [
      #   ""
      # ];
    };

    services.kanshi = {
      enable = true;
      settings = [
        {
          profile = {
            name = "pc-only";
            outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
                scale = 1.0;
                mode = "1920x1200@60Hz";
                position = "3473,1080";
              }
            ];
          };
        }
        {
          profile = {
            name = "docked";
            outputs = [
              {
                criteria = "eDP-1";
                status = "disable";
                position = "3473,1080";
              }
              {
                criteria = "DP-5";
                mode = "1920x1080@60Hz";
                position = "1280,0";
                status = "enable";
              }
              {
                criteria = "DP-6";
                mode = "1920x1080@74.97Hz";
                position = "3200,0";
                status = "enable";
              }
              {
                criteria = "DP-7";
                mode = "1920x1080@74.97Hz";
                position = "5120,0";
                status = "enable";
              }
            ];
          };
        }
        /*
           {
          profile = {
            name = "docked-alt";
            outputs = [
              {
                criteria = "eDP-1";
                # status = "disable";
                status = "enable";
              }
              {
                criteria = "DP-11";
                mode = "1920x1080@60Hz";
                position = "3840,0";
                status = "enable";
              }
              {
                criteria = "DP-10";
                mode = "1920x1080@60Hz";
                position = "0,0";
                status = "enable";
              }
              {
                criteria = "DP-12";
                mode = "1920x1080@60Hz";
                position = "1920,0";
                status = "enable";
              }
            ];
          };
        }
        */
      ];
    };

    home.packages = with pkgs; [
      # hyprdynamicmonitors
    ];
  };
}
