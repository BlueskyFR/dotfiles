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
    ./cuda.nix
  ];

  # Get with `head -c 8 /etc/machine-id` or random;
  ## required by ZFS to ensure dataset is not being imported on the wrong machine
  networking.hostId = "014117ef";

  home-manager.users.hugo = {};
}
