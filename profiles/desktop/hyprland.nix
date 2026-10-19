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

    # UWSM (see `withUWSM` in ./default.nix) already manages the session/graphical-session.target;
    # HM's integration (`dbus-update-activation-environment` + `hyprland-session.target` exec-once) conflicts with it
    ## See https://wiki.hypr.land/Useful-Utilities/Systemd-start/
    systemd.enable = false;

    # TODO: switch to lua when stable enough
    configType = "hyprlang";

    settings = {
      # Startup apps
      # (move to workspace only applies to non-forking processes
      # since it is PID-based)
      ## Apps should be started with `uwsm app -- <cmd>` so they run in their own unit instead of Hyprland's
      ## (https://wiki.hypr.land/Useful-Utilities/Systemd-start/), BUT exec rules like `[workspace N]`/`[float]`
      ## match the PID, which `uwsm app` may break (untested; scope mode should exec in place): entries using them are left unwrapped on purpose
      # TODO: drop the exec rule for a class-based `windowrule` (already exists for code/firefox) to allow wrapping
      exec-once = [
        "[workspace 1] alacritty"
        "[workspace 2 silent] code"
        "[workspace 3 silent] firefox"

        # System tray icons
        ## Removed: UWSM runs XDG autostart entries, which already start both (would duplicate the tray icons)
        ## (`nm-applet.desktop` from HM's networkmanagerapplet package, `blueman.desktop` from `services.blueman`)
        # "sleep 10 && nm-applet"
        # "sleep 10 && blueman-applet"
      ];

      # Also exec on reloads
      exec = [
        # Lift all workspace placement rules after startup or reload
        "sleep 25 && hyprctl keyword windowrule workspace unset, 'match:class .*'"

        # NixOS configuration on workspace 10
        ## The '*' needs to be shell-escaped, and the '\` itself needs to be escaped in the nix
        ## string in order to be passed to the shell;
        ## The `workspace X silent` is a static rule, meaning it cannot apply to dynamic tags
        ## so we make it dynamic manually by triggering it a couple seconds after startup
        "sleep 10 && hyprctl dispatch movetoworkspacesilent '10,tag:nixos-conf\\*'"
      ];

      # Window rules
      ## Info about class/title/status: `hyprctl clients`
      windowrule = [
        # Fix for the forking processes mentionned above during startup
        "workspace 2 silent, match:class code"
        # NixOS configuration on workspace 10
        "tag +nixos-conf, match:class code, match:title NixOS configuration"
        # Static rule, doesn't work on dynamic tags:
        # "workspace 10 silent, tag:nixos-conf*"
        "workspace 3 silent, match:class vivaldi-stable"
        "workspace 3 silent, match:class firefox"

        # Picture-in-Picture
        "float on, pin on, keep_aspect_ratio on, match:title (Picture in picture|Picture-in-Picture)"

        # Disable VRR for MPV (fixes flickering)
        "no_vrr 1, match:class ^(mpv)$"
      ];

      # Environment variables
      ## Under UWSM, `env` only reaches Hyprland and its direct children, not systemd services
      ## (DMS, portals, XDG autostart, `uwsm app` units), so they were moved out of here
      ## (https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/):
      ## - Nvidia ones: `environment.sessionVariables` in hosts/*/nvidia.nix (per-host, were applied everywhere)
      ## - Toolkit ones: `xdg.configFile."uwsm/env"` below
      ## - `HYPR*`/`AQ_*` ones belong to `xdg.configFile."uwsm/env-hyprland"` (none for now)
      # env = [
      #   # Dropped: UWSM sets the XDG session variables itself
      #   "XDG_SESSION_TYPE,wayland"
      #   # Dropped: obsolete, superseded by `cursor.no_hardware_cursors` below
      #   "WLR_NO_HARDWARE_CURSORS,1"
      # ];

      # XWayland tweaks
      xwayland.force_zero_scaling = true;

      cursor.no_hardware_cursors = 1;

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
          ## Long-lived apps are launched with `uwsm app --` (see `exec-once` above), except the ones
          ## using `[float; ...]` exec rules (PID-based) which are left unwrapped for the same reason (to be tested)
          "$mod, Return, exec, uwsm app -- alacritty"
          "$mod, V, exec, uwsm app -- vivaldi"
          "$mod, B, exec, uwsm app -- firefox"
          "$mod, S, exec, uwsm app -- nautilus --new-window"
          "$mod, A, killactive"
          "$mod SHIFT, A, forcekillactive"
          ", Print, exec, hyprshot --clipboard-only -d -m region"
          "$mod, space, togglefloating"
          # Apps are launched through `uwsm app --` with rofi's `run-command` (see ./rofi.nix)
          "$mod, D, exec, rofi -show drun -show-icons"
          # See https://wiki.hypr.land/Configuring/Dwindle-Layout/#layout-messages
          "$mod, E, layoutmsg, togglesplit"
          "$mod, Z, fullscreen, 1"
          "$mod, F, fullscreen, 0"
          "$mod, G, togglegroup"
          "$mod, H, changegroupactive, f"
          # "$mod, P, pseudo"
          # Make the app/client fullscreen but keep the window non-fullscreen
          # (fake fullscreen)
          "$mod, P, fullscreenstate, 0 2"
          "$mod, O, exec, uwsm app -- nwg-displays"
          "$mod, L, exec, uwsm app -- hyprlock"
          "$mod SHIFT, R, exec, hyprctl reload"
          # 768 is in pixels; 768 = (3840px / 1.5x) * 33%
          "$mod, M, exec, [float; size 768 60%] pwvucontrol"
          "$mod, C, exec, [float; size 650 350; center; pin] alacritty --command ${lib.getExe pkgs.python314} -q"
          # Shonan Beach FM
          "$mod, equal, exec, [float; size 350 150; pin] ${lib.getExe' pkgs.ffmpeg "ffplay"} -hide_banner https://shonanbeachfm.out.airtime.pro/shonanbeachfm_c"
          # Exit Hyprland
          ## `exit` interferes with UWSM's ordered shutdown sequence (https://wiki.hypr.land/Configuring/Basics/Dispatchers/);
          ## if units get stuck, fallback is `loginctl terminate-user ""`
          # "$mod SHIFT, E, exit"
          "$mod SHIFT, E, exec, uwsm stop"
          "$mod, J, exec, uwsm app -- jellyfin-desktop"

          # Advanced binds
          ## Brightness control
          ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.acpilight} -perceived -dec 10"
          ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.acpilight} -perceived -inc 10"

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
                # Same but silent (doesn't switch workspace) with ALT instead
                "$mod ALT, ${wsKey}, movetoworkspacesilent, ${ws}"

                # Move active window to workspace [0-9] + place it on the other screen
                ## 1. Move the window silently/in the background to it
                "$mod CTRL, ${wsKey}, movetoworkspacesilent, ${ws}"
                ## 2. Then move the target workspace relative to the still active monitor
                "$mod CTRL, ${wsKey}, moveworkspacetomonitor, ${ws} -1"
                ## 3. Finally switch to it!
                "$mod CTRL, ${wsKey}, workspace, ${ws}"

                # Now same but silently/without switching to it at the end!
                "$mod CTRL ALT, ${wsKey}, movetoworkspacesilent, ${ws}"
                "$mod CTRL ALT, ${wsKey}, moveworkspacetomonitor, ${ws} -1"
                "$mod CTRL ALT, ${wsKey}, workspace, ${ws}"
                ## Just switch back to the previous on top of that ;)
                "$mod CTRL ALT, ${wsKey}, workspace, previous"
              ]
            )
            10)
        );

      # m = movement is expected, drag_threshold is configurable (a click won't count)
      # (drag_threshold is 0 by default though!)
      # Bind flags: https://wiki.hypr.land/Configuring/Binds/#bind-flags
      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"

        # Move window using mouse button 5
        ", mouse:277, movewindow"
      ];

      # l = works even when screen is locked
      bindl = [
        # `playerctl` acts on the app currently playing some media
        # Bluetooth events (keys) can be debugged using `sudo evtest`
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        # Use wpctl (Wireplumber) for volume control to change the system volume
        # instead of the app's volume (if it was playerctl)
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume --limit 1.0 @DEFAULT_SINK@ 5%+"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
      ];

      # le = will repeat when held even when screen is locked
      bindle = [
        # Seek forward/backward X seconds when combining with CTRL
        # (to avoid conflicting with regular key presses)
        "CTRL, XF86AudioPrev, exec, playerctl position 5-"
        "CTRL, XF86AudioNext, exec, playerctl position 5+"

        # Control the app volume when using CTRL + volume keys
        "CTRL, XF86AudioLowerVolume, exec, playerctl volume 0.05-"
        "CTRL, XF86AudioRaiseVolume, exec, playerctl volume 0.05+"
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
        # pseudotile = "yes"; # Bound to $mod + P  # Removed?
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

      ecosystem = {
        no_donation_nag = true;
      };
    };
  };

  # Session-wide environment, sourced by UWSM before starting Hyprland so systemd services see it too
  ## (theming/toolkit vars, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/)
  ## Changes only apply after logging out and back in
  xdg.configFile."uwsm/env".text = ''
    # Flickering issues
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    # XWayland tweaks
    export GDK_SCALE=2
  '';
}
