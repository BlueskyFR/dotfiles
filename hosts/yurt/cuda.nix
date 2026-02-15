{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # environment.systemPackages = with pkgs; [egl-wayland wayland-protocols];

  # Load Nvidia driver for Xorg and Wayland
  ## Weird but required to provide `nvidia-smi` somehow
  services.xserver.videoDrivers = ["nvidia"];

  # Enable CUDA binary cache
  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  # environment.systemPackages = with pkgs; [
  #   cudaPackages.cuda_cudart
  #   cudaPackages.cudnn
  #   ffmpeg
  #   libGLU
  #   libGL
  #   freeglut
  # ];

  # TODO: move into a server-cuda module? or an option of the server module?
  hardware.nvidia-container-toolkit.enable = true;

  hardware = {
    # Enable OpenGL
    graphics = {
      enable = true;
      # extraPackages = with pkgs; [intel-media-driver libvdpau-va-gl];
    };

    nvidia = {
      # Modesetting is required
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = true;

      # Package channel to use
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Enable the `nvidia-settings` menu
      nvidiaSettings = false;
      nvidiaPersistenced = true;

      videoAcceleration = true;
    };
  };
}
