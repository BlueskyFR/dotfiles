{
  inputs,
  pkgs,
  lib,
  self,
  config,
  flakeDir,
  ...
}: {
  imports = [./steam.nix];

  home-manager.users.hugo = {
    home.packages = with pkgs; [
      lunar-client # Minecraft alt. launcher
    ];
  };

  # Kernel-side driver that improves NT sync primitives; huge speed gain for Wine-based apps for instance
  boot.kernelModules = ["ntsync"];
}
