{
  pkgs,
  lib,
  ...
}: {
  # imports = [];
  home-manager.users.hugo.imports = [./home.nix];

  # Enable LLDP through lldpd and lldpcli (e.g. `sudo lldpcli show neighbors`)
  services.lldpd.enable = true;
}
