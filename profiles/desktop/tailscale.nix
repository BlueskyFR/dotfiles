{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  services.tailscale = {
    enable = true;
  };

  home-manager.users.hugo = {
    services.tailscale-systray.enable = true;
  };
}
