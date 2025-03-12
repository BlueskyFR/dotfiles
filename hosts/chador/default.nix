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

  home-manager.users.hugo = {
    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkForce [
        "eDP-1, highres, auto, 1.25"
        ", preferred, auto, auto"
      ];
    };
  };
}
