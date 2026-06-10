{
  inputs,
  pkgs,
  lib,
  self,
  config,
  flakeDir,
  ...
}: {
  programs = {
    steam = {
      enable = true;
      # Loads the extest library into Steam (translates X11 input events to uinput events, useful on Wayland)
      extest.enable = true;
      gamescopeSession.enable = true;
    };
    gamemode = {
      # View gamemode status with `gamemoded -s`;
      # run tests with `gamemoded -t`
      enable = true;
      # Increase priority of spawned process
      enableRenice = true;
      settings = {
        general = {
          softrealtime = "auto";
          # Increase priority of spawned process using renice (Linux util)
          renice = 10;
        };
        custom = {
          start = "notify-send -a 'Gamemode' 'Optimizations activated'";
          end = "notify-send -a 'Gamemode' 'Optimizations deactivated'";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [steam-run];
  # Add user to the privileged `gamemode` group so that processes priority can be changed
  users.users.hugo.extraGroups = ["gamemode"];

  # This fix doubles my DL speed; see https://github.com/ValveSoftware/steam-for-linux/issues/10248#issuecomment-2408442977
  home-manager.users.hugo = {
    home.file.".steam/steam/steam_dev.cfg" = {
      text = ''
        @nClientDownloadEnableHTTP2PlatformLinux 0
        @fDownloadRateImprovementToAddAnotherConnection 1.0
      '';
      force = true;
    };
  };
}
