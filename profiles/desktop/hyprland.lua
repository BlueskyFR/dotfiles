-- Import our nix.lua containing variables we export from our nix config;
-- allows independent lua config while keeping nix variable interpolation
local nix = require("nix")

-- Import our imperatively-generated monitors config if it exists;
-- nwg-displays generates `$XDG_CONFIG_HOME/hypr/monitors.lua`
-- (`pcall` = protected call/doesn't crash if non-existent)
pcall(require, "monitors")

local mod = "SUPER"
-- Define & use workspaces by their id, and give them a default_name simply for display
local workspaces = {
  -- The left side of the `=` are workspace IDs, which is what we use to refer them;
  -- the `name` is purely for display.
  -- Workspace id must be > 0 or an str key
  ["99"] = { name = "ai", key = "twosuperior" },
  ["1"] = { name = "1 · term", key = "ampersand" },
  ["2"] = { name = "2 · code", key = "eacute" },
  ["3"] = { name = "3 · browser", key = "quotedbl" },
  ["4"] = { name = "4 · chat", key = "apostrophe" },
  ["5"] = { name = "5", key = "parenleft" },
  ["6"] = { name = "6", key = "minus" },
  ["7"] = { name = "7", key = "egrave" },
  ["8"] = { name = "8", key = "underscore" },
  ["9"] = { name = "9 · music", key = "ccedilla" },
  ["10"] = { name = "10 · conf", key = "agrave" },

  -- FIXME: switch back to the below when this issue gets closed:
  -- FIXME: https://github.com/duxlabs-dev/dux-shell/issues/4301

  -- ai = { name = "ai", key = "twosuperior" },
  -- term = { name = "1 · term", key = "ampersand" },
  -- code = { name = "2 · code", key = "eacute" },
  -- browser = { name = "3 · browser", key = "quotedbl" },
  -- chat = { name = "4 · chat", key = "apostrophe" },
  -- ["5"] = { name = "5", key = "parenleft" },
  -- ["6"] = { name = "6", key = "minus" },
  -- ["7"] = { name = "7", key = "egrave" },
  -- ["8"] = { name = "8", key = "underscore" },
  -- music = { name = "9 · music", key = "ccedilla" },
  -- conf = { name = "10 · conf", key = "agrave" },
}

-- Workspaces config
for ws_id, ws in pairs(workspaces) do
  -- Assign a name to our workspace id
  hl.workspace_rule({ workspace = ws_id, default_name = ws.name })

  -- Switch to the workspace
  hl.bind(mod .. " + " .. ws.key, hl.dsp.focus({ workspace = ws_id }))

  -- Move the active window to workspace
  hl.bind(mod .. " + SHIFT + " .. ws.key, hl.dsp.window.move({ workspace = ws_id }))
  -- Same, but silently (without following it)
  hl.bind(mod .. " + ALT + " .. ws.key, hl.dsp.window.move({ workspace = ws_id, follow = false }))

  -- TODO: old additional mappings not ported yet. Improve?
end

-- Startup apps temporary placement rules

-- List of: {
--   cmd: command to run
--   workspace?: str (optional)
--   class?: str, set for forking apps
--   focus?: bool, true to switch to that workspace after starting (opens silently by default)
-- }
local startup_apps = {
  { cmd = "alacritty",                 workspace = "1", focus = true },
  { cmd = "code",                      workspace = "2", class = "code" },
  { cmd = "firefox",                   workspace = "3", class = "firefox" },

  -- System tray icons, delayed after Dux Shell start
  { cmd = "sleep 10 && nm-applet" },
  { cmd = "sleep 10 && blueman-applet" },
}
-- And add per-profile/host overrides from nix to this list
for _, app in ipairs(nix.autostart) do
  table.insert(startup_apps, app)
end

-- The time after which to lift window placement rules
local STARTUP_GRACE_MS = 25000

-- Startup apps (not ran on reloads)
hl.on("hyprland.start", function()
  -- Hyprland boots on the numbered workspace 1, which we don't use: leave it
  -- hl.dispatch(hl.dsp.focus({ workspace = "term" }))

  -- Small helper that appends " silent" unless the startup app requests focus,
  -- or nil if no workspace is requested
  local function placement(app)
    return app.workspace and app.workspace .. (app.focus and "" or " silent")
  end

  -- Temporary startup rules, valid until STARTUP_GRACE_MS
  local startup_rules = {}

  -- For each startup app:
  for i, app in ipairs(startup_apps) do
    local target_ws = placement(app)
    -- Create a rule to handle forking processes, if both a class and a workspace are set
    if app.class and target_ws then
      table.insert(startup_rules, hl.window_rule({
        name = "startup-" .. i .. "-" .. app.class,
        match = { class = app.class },
        workspace = target_ws,
      }))
    end

    -- Start it on the requested workspace (this placement will only work for non-forking processes)
    hl.exec_cmd(app.cmd, { workspace = target_ws })
  end

  -- Now that we started all of our apps, lift the temporary rules we created after STARTUP_GRACE_MS
  hl.timer(function()
    for _, rule in ipairs(startup_rules) do
      rule:set_enabled(false)
    end
  end, { timeout = STARTUP_GRACE_MS, type = "oneshot" })
end)

-- Monitors & color management

-- Global settings
hl.config({
  -- Color mode
  render = { cm_enabled = true, cm_auto_hdr = 1 },
  -- Input configuration
  input = {
    kb_layout = "fr",
    accel_profile = "flat",
    numlock_by_default = true,
    touchpad = { natural_scroll = true },
  },

  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,

    col = {
      active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Sets the default tiling layout
    layout = "dwindle",
  },

  decoration = {
    rounding = 8,
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
    },
  },

  ecosystem = {
    no_donation_nag = true,
  },
})

-- Curves & animations
--- Bezier curves
hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })
hl.curve("easeOutQuart", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("easeOutBack", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "overshot", style = "slide" })
--- Zoom-out closing effect
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "overshot", style = "slidefade" })

-- Apply custom monitors setups
for _, monitor in ipairs(nix.monitors) do
  hl.monitor(monitor)
end


-- Some helpers
local exec = hl.dsp.exec_cmd
-- Size as a fraction of the active monitor, in logical pixels;
-- w and h both as percentages (0.0-1.0)
local function monitor_fraction(w, h)
  local m = hl.get_active_monitor()
  return { x = math.floor(w * m.width / m.scale), y = math.floor(h * m.height / m.scale) }
end

-- Binds

hl.bind(mod .. " + Return", exec("alacritty"))
hl.bind(mod .. " + V", exec("firefox"))
-- Modern bluetooth mgmt GUI
hl.bind(mod .. " + B", exec(nix.overskride))
hl.bind(mod .. " + S", exec("nautilus --new-window"))
hl.bind(mod .. " + A", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + A", hl.dsp.window.kill())
hl.bind("Print", exec("hyprshot --clipboard-only -d -m region"))
hl.bind(mod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + D", exec("rofi -show drun -show-icons"))
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + Z", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- Make the app fullscreen but keep the window non-fullscreen (fake fullscreen)
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + H", hl.dsp.group.next())
hl.bind(mod .. " + P", exec("nwg-displays"))
-- dux-shell lockscreen
hl.bind(mod .. " + L", exec("dms ipc call lock lock"))
hl.bind(mod .. " + SHIFT + R", exec("hyprctl reload"))
-- FIXME: doesn't fully work bc it forks
hl.bind(mod .. " + M", exec("pwvucontrol", { float = true, size = { 768, "monitor_h * 0.6" } }))
hl.bind(mod .. " + SHIFT + M", exec(nix.zestbay))
hl.bind(mod .. " + C", exec(
  "alacritty --command " .. nix.python .. " -q",
  { float = true, size = { 650, 350 }, center = true, pin = true }
))
-- Shonan Beach FM
hl.bind(mod .. " + F12", exec(
  nix.ffplay .. " -hide_banner https://shonanbeachfm.out.airtime.pro/shonanbeachfm_c",
  { float = true, size = { 350, 150 }, pin = true }
))
hl.bind(mod .. " + J", exec("jellyfin-desktop"))
-- Exit Hyprland
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())

-- Brightness control
hl.bind("XF86MonBrightnessDown", exec(nix.acpilight .. " -perceived -dec 10"))
hl.bind("XF86MonBrightnessUp", exec(nix.acpilight .. " -perceived -inc 10"))

-- Move focus with mod + arrows, move the window with mod + SHIFT + arrows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(mod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
  hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Move workspaces to other monitors
hl.bind(mod .. " + W", hl.dsp.focus({ workspace = "previous", on_current_monitor = true }))
hl.bind(mod .. " + X", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mod .. " + SHIFT + X", hl.dsp.workspace.move({ monitor = "-1" }))

-- Scroll through existing workspaces with mod + scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad
hl.bind(mod .. " + equal", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + equal", function()
  hl.dispatch(hl.dsp.window.float({ action = "enable" }))
  hl.dispatch(hl.dsp.window.resize(monitor_fraction(0.9, 0.85)))
  hl.dispatch(hl.dsp.window.center())
  hl.dispatch(hl.dsp.window.move({ workspace = "special:scratch" }))
end)

-- Move/resize windows with mod + LMB/RMB and dragging
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- Move window using mouse button 5
hl.bind("mouse:277", hl.dsp.window.drag(), { mouse = true })

-- Works even when the screen is locked
local locked = { locked = true }
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), locked)
hl.bind("XF86AudioPause", exec("playerctl play-pause"), locked)
hl.bind("XF86AudioPrev", exec("playerctl previous"), locked)
hl.bind("XF86AudioNext", exec("playerctl next"), locked)
-- wpctl changes the system volume, not the app's
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_SINK@ 5%-"), locked)
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume --limit 1.0 @DEFAULT_SINK@ 5%+"), locked)
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_SINK@ toggle"), locked)

-- Repeats when held, even when the screen is locked
local locked_repeat = { locked = true, repeating = true }
-- Seek and app volume when combined with CTRL
hl.bind("CTRL + XF86AudioPrev", exec("playerctl position 5-"), locked_repeat)
hl.bind("CTRL + XF86AudioNext", exec("playerctl position 5+"), locked_repeat)
hl.bind("CTRL + XF86AudioLowerVolume", exec("playerctl volume 0.05-"), locked_repeat)
hl.bind("CTRL + XF86AudioRaiseVolume", exec("playerctl volume 0.05+"), locked_repeat)


-- Persistent rules
--- Info about class/title/status: `hyprctl clients`

-- Picture-in-Picture
hl.window_rule({
  match = { title = "(Picture in picture|Picture-in-Picture)" },
  float = true,
  pin = true,
  keep_aspect_ratio = true,
})

-- Disable VRR for MPV (fixes flickering)
hl.window_rule({ match = { class = "^(mpv)$" }, no_vrr = true })

-- "NixOS configuration" vscode window: send it to workspace 10 as soon as its title says so
local nixos_conf_listener
nixos_conf_listener = hl.on("window.title", function(w)
  if w == nil or w.class ~= "code" then return end
  if not w.title:find("NixOS configuration", 1, true) then return end

  -- Only place it once, then stop listening
  nixos_conf_listener:remove()
  hl.dispatch(hl.dsp.window.move({ workspace = "10", follow = false, window = w }))
end)
