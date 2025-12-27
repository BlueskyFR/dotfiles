{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  # This file holds some beta/unstable features/configurations, promising but unstable/experimental

  # Increases download speeds sometimes slow from cache.nixos.org
  ## See https://wiki.nixos.org/wiki/Maintainers:Fastly#Cache_v2_plans
  # nix.settings.substituters = ["https://aseipp-nix-cache.global.ssl.fastly.net"];
}
