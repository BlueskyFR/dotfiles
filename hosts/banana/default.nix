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
      monitor = lib.mkForce [];
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
                mode = "1920x1200@60.00Hz";
              }
            ];
            # Switching back to a single monitor is broken unless `hyprctl monitors all` is ran for some reason...
            # Issue reported at https://gitlab.freedesktop.org/emersion/kanshi/-/issues/127
            # exec = ["sleep 3 && hyprctl monitors all"];
          };
        }
        {
          profile = {
            name = "docked";
            outputs = [
              {
                criteria = "eDP-1";
                status = "disable";
              }
              {
                # criteria = "DP-8";
                # Can also be `A  space-separated string containing the output manufacturer, model and serial number
                # (e.g. "Foocorp ASDF 1234")`, equivalent to the description field on `hyprctl monitors all` if no
                # field is unknown (If one of these fields is missing, it needs to be populated with the string
                # "Unknown" (e.g. "Foocorp ASDF Unknown").)
                criteria = "Hewlett Packard HP E240 6CM7170460";
                mode = "1920x1080@60Hz";
                position = "1280,0";
                status = "enable";
              }
              {
                # criteria = "DP-9";
                criteria = "HP Inc. HP E24m G4 CNC3230PMC";
                mode = "1920x1080@74.97Hz";
                position = "3200,0";
                status = "enable";
              }
              {
                # criteria = "DP-10";
                criteria = "HP Inc. HP E24m G4 CNC3280PQG";
                mode = "1920x1080@74.97Hz";
                position = "5120,0";
                status = "enable";
              }
            ];
          };
        }
      ];
    };

    home.packages = with pkgs; [
      # hyprdynamicmonitors
    ];
  };
}
