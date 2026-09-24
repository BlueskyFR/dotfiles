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
    programs = {
      claude-code = {
        enable = true;
      };
    };

    home.packages = with pkgs; [
      # TODO: install desktop only on the desktop profile
      llm-agents.claude-desktop
      # Required to be in path by claude-desktop for the Discord integration
      bun

      claude-monitor
    ];
  };
}
