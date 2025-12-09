{
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    # Set the Hyprland and xdg-desktop-portal packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    settings = {
      # Startup apps
      # (move to workspace only applies to non-forking processes
      # since it is PID-based)
      exec-once = [
        "[workspace 1] alacritty"
        "[workspace 2 silent] code"
        "[workspace 3 silent] vivaldi"
        "[workspace 4 silent] discord"
        # Lift all workspace placement rules after startup
        "sleep 40 && hyprctl keyword windowrule workspace unset, class:.*"
      ];

      # Window rules
      ## Info about class/title/status: `hyprctl clients`
      windowrule = [
        # Fix for the forking processes mentionned above during startup
        "workspace 2 silent, class:code"
        "workspace 3 silent, class:vivaldi-stable"
        "workspace 4 silent, class:discord"

        # Picture-in-Picture
        "pin, title:'Picture in picture'"
      ];

      # Required for Nvidia drivers
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
        "NVD_BACKEND,direct"
        # Flickering issues
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      # Monitors configuration
      # monitor = name, resolution, position, scale
      # Position: X is normal but Y is reversed
      monitor = lib.mkDefault [
        # "DP-3, highrr, 1920x-360, auto, vrr, 1" # Variable refresh rate, 1 = on
        # "DP-2, highres, 0x0, auto"
      ];
      # Support defining monitors imperatively and dynamically using nwg-displays;
      # to support it you must force `monitor = lib.mkForce [];` above and per-host.
      source = "~/.config/hypr/monitors.conf";

      "$mod" = "SUPER";
      bind =
        [
          # Standard binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mod, Return, exec, alacritty"
          "$mod, V, exec, vivaldi"
          "$mod, A, killactive"
          "$mod SHIFT, X, forcekillactive"
          ", Print, exec, grimblast --notify copysave area"
          "$mod, space, togglefloating"
          "$mod, D, exec, rofi -show drun -show-icons"
          "$mod, E, togglesplit"
          "$mod, Z, fullscreen, 1"
          "$mod, F, fullscreen, 0"
          "$mod, G, togglegroup"
          "$mod, H, changegroupactive, f"
          "$mod, P, pseudo"
          # 768 is in pixels; 768 = (3840px / 1.5x) * 33%
          "$mod, M, exec, [float; size 768 60%] pavucontrol"
          # Exit Hyprland
          "$mod SHIFT, E, exit"

          # Advanced binds
          ## Brightness control
          # ", XF86MonBrightnessDown, exec, /run/current-system/sw/bin/light -u 10"
          # ", XF86MonBrightnessUp, exec, /run/current-system/sw/bin/light -A 10"

          # Move focus with $mod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Move window in a certain direction with shift + arrow keys
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # Move workspaces to other monitors
          "$mod, W, focusworkspaceoncurrentmonitor, previous"
          "$mod, X, movecurrentworkspacetomonitor, +1"
          "$mod SHIFT, X, movecurrentworkspacetomonitor, -1"

          # Scroll through existing workspaces with $mod + scroll
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # Special workspace (scratchpad)
          "$mod, twosuperior, togglespecialworkspace"
          "$mod SHIFT, twosuperior, setfloating, active"
          "$mod SHIFT, twosuperior, resizeactive, exact 90% 85%"
          "$mod SHIFT, twosuperior, centerwindow, 1"
          "$mod SHIFT, twosuperior, movetoworkspace, special"
        ]
        ++ (
          # Workspaces
          # Binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          # Key codes can be retrieved using `wev`
          builtins.concatLists (builtins.genList (
              x: let
                azertyKeys = ["ampersand" "eacute" "quotedbl" "apostrophe" "parenleft" "minus" "egrave" "underscore" "ccedilla" "agrave"];
                wsKey = builtins.elemAt azertyKeys x;
                ws = builtins.toString (x + 1);
              in [
                # Switch workspace with $mod + [0-9]
                "$mod, ${wsKey}, workspace, ${ws}"
                # Move active window to a workspace with $mod + SHIFT + [0-9]
                "$mod SHIFT, ${wsKey}, movetoworkspace, ${ws}"
              ]
            )
            10)
        );

      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      input = {
        kb_layout = "fr";
        accel_profile = "flat";
        numlock_by_default = true;
        touchpad.natural_scroll = "yes";
      };

      # Tiling layout using a binary tree, similar to i3
      dwindle = {
        # See https://wiki/hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = "yes"; # Bound to $mod + P
        preserve_split = "yes";
      };

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        # Sets the default tiling layout
        layout = "dwindle";
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        rounding = 8; # 10
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        bezier = [
          "overshot, 0.13, 0.99, 0.29, 1.1"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutQuart, 0.25, 1, 0.5, 1"
          "easeOutBack, 0.34, 1.56, 0.64, 1"
        ];
        animation = [
          # "windows, 1, 4, overshot, slide"
          # "border, 1, 10, default"
          # "fade, 1, 10, default"
          # "workspaces, 1, 6, overshot, slide"
          "windows, 1, 4, overshot, slide"
          # "windows, 1, 4, easeOutBack, gnomed"
          "windowsOut, 1, 4, default" # Zoom-out closing effect
          "border, 1, 10, default"
          "fade, 1, 4, default"
          "workspaces, 1, 4.5, overshot, slidefade"
          #"specialworkspace, 1, 8, default, slidefadevert"
        ];
      };
      #windowrule=animation slide,title:^(all_is_kitty)$
    };
  };
}
