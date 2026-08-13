{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  home.packages = with pkgs; [
  ];

  home.shellAliases = {
    # Enable FPV videos stabilization (without a GUI) on any personal device
    stabilize = "${lib.getExe' pkgs.gyroflow "gyroflow"} --parallel-renders 8 --preset \"{'version':2,'name':'dynamic-preset-o4','output':{'audio':true,'codec':'H.265/HEVC','use_gpu':true},'stabilization':{'lens_correction_amount':1,'method':'Default','smoothing_params':[{'name':'smoothness','value':0.12},{'name':'smoothness_pitch','value':0.5},{'name':'smoothness_yaw','value':0.5},{'name':'smoothness_roll','value':0.5},{'name':'per_axis','value':0},{'name':'trim_range_only','value':1},{'name':'max_smoothness','value':1},{'name':'alpha_0_1s','value':0.08}],'use_gravity_vectors':false,'video_speed':1,'video_speed_affects_smoothing':true,'video_speed_affects_zooming':true,'video_speed_affects_zooming_limit':true}}\"";
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 4 silent] discord"
      "[workspace 9 silent] spotify"
    ];
    windowrule = [
      "workspace 4 silent, match:class discord"
      "workspace 9 silent, match:class spotify"
    ];
  };
}
