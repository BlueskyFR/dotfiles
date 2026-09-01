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
}
