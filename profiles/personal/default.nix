{
  pkgs,
  lib,
  ...
}: {
  # imports = [];
  home-manager.users.hugo.imports = [./home.nix];

  hyprland-variables = {
    autostart = [
      {
        cmd = "discord";
        workspace = "4";
        class = "discord";
      }
      {
        cmd = "spotify";
        workspace = "9";
        class = "spotify";
      }
    ];
  };
}
