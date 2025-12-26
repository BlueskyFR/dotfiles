{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  # Enable PAM access for Hyprlock
  security.pam.services.hyprlock = {};

  home-manager.users.hugo = {
    programs.hyprlock = {
      enable = true;
      # Custom fix: https://github.com/hyprwm/hyprlock/pull/938
      package = inputs.custom-hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.default;
      settings = {
        animations = {
          enabled = true;
          # Syntax: bezier = name, X0, Y0, X1, Y1
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            # Syntax: name, on/off, speed, curve
            ## speed is the amount of ds (1ds = 100ms) the animation will take
            "fadeIn, 1, 5, linear"
            "fadeOut, 1, 3, linear"
            "inputFieldDots, 1, 2, linear"
            "inputFieldColors, 1, 3, linear"
          ];
        };

        background = {
          blur_passes = 1;
          blur_size = 4;
          color = "rgba(34, 34, 34, 1)";
          path = "screenshot";
          zindex = -1;
        };

        general = {
          ignore_empty_input = true;
          text_trim = false;
          hide_cursor = true;
        };

        input-field = {
          monitor = "";
          # size=20%, 5%
          # dots_spacing=0.300000
          fade_on_empty = false;
          # fail_text=$PAMFAIL
          fail_text = "";
          # font_family=$font
          # font_family = "monospace";
          font_family = "FiraCode Nerd Font Mono Ret";
          # font_family = VictorMono Nerd Font Mono
          halign = "center";
          # placeholder_text=Input password...
          position = "0, 0";
          rounding = 0;
          valign = "center";

          outline_thickness = 5;

          size = "99%, 99%";
          dots_text_format = "*";
          dots_size = 0.1;
          dots_spacing = 0.15;

          # hide_input = true

          # outer_color=rgba(33ccffee) rgba(00ff99ee) 45deg
          outer_color = "rgba(0, 0, 0, 0.0)";
          inner_color = "rgba(0, 0, 0, 0.0)";
          font_color = "rgba(255, 255, 255, 1)";

          # Colors
          fail_color = "rgb(255, 49, 23)";
          check_color = "rgba(255, 255, 255, 0.5)";
          numlock_color = "rgb(255, 128, 0)";
          invert_numlock = true;
          capslock_color = "rgb(255, 128, 0)";

          placeholder_text = "";
        };

        label = {
          monitor = "";
          # font_family = JetBrains Mono Nerd Font Mono ExtraBold;
          font_family = "VictorMono Nerd Font Mono Bold";
          # font_size = 90;
          font_size = 112;
          halign = "center";
          position = "0, -100";
          shadow_boost = 0.5;
          shadow_passes = 3;
          text = "$TIME";
          color = "rgba(255, 255, 255, 0.65)";
          valign = "top";
          zindex = 3;
        };
      };
    };
  };
}
