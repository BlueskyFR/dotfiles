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

  # Orca mobile remote
  networking.firewall.allowedTCPPorts = [6768];

  home-manager.users.hugo = {config, ...}: {
    programs = {
      claude-code = {
        enable = true;
        # New in HM 26.11 (TODO: remove when upgrading)
        configDir = "${config.xdg.configHome}/claude";
      };
    };

    home.packages = with pkgs; [
      # TODO: install desktop only on the desktop profile
      llm-agents.claude-desktop
      opencode-desktop

      llm-agents.orca
      # Required to be in path by claude-desktop for the Discord integration
      bun

      claude-monitor
    ];
  };
}
