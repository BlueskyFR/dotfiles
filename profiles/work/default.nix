{
  pkgs,
  lib,
  ...
}: {
  # imports = [];
  home-manager.users.hugo.imports = [./home.nix];
}
