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
}
