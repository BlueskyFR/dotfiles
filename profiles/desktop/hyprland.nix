{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  options = {
    # Allow each host to override exported variables to nix.lua
    hyprland-variables = lib.mkOption {
      type = (pkgs.formats.json {}).type;
      default = {};
    };
  };

  config = {
    # Some variables that we export to a nix.lua so that nix variable interpolation can be used
    hyprland-variables = {
      # Some important things we may want to override per-host or per-profile
      monitors = [];
      # List of `{cmd = "str", workspace = "id", class? = "str"}`
      autostart = [];

      overskride = lib.getExe pkgs.overskride;
      zestbay = lib.getExe pkgs.zestbay;
      python = lib.getExe pkgs.python315;
      ffplay = lib.getExe' pkgs.ffmpeg "ffplay";
      acpilight = lib.getExe pkgs.acpilight;
    };

    home-manager.users.hugo = {
      wayland.windowManager.hyprland = {
        enable = true;
        # Set the Hyprland and xdg-desktop-portal packages to null to use the ones from the NixOS module
        package = null;
        portalPackage = null;
      };

      # Now export the above block we defined to a nix.lua file
      xdg.configFile."hypr/nix.lua".text = "return " + lib.generators.toLua {} config.hyprland-variables;

      # Use our independent lua file rather than using Nix's weird lua-in-nix thing
      xdg.configFile."hypr/hyprland.lua" = {
        source = ./hyprland.lua;
      };
    };
  };
}
