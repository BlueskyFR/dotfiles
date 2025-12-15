{config, ...}: {
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  # Blacklist nouveau
  boot.blacklistedKernelModules = ["nouveau"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
    nvidiaPersistenced = false;
    # Enable if screen tearing issues, slows down driver startup
    forceFullCompositionPipeline = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    prime = {
      # Use GPU by default if true
      sync.enable = false;
      # OR enable GPU offload
      offload = {
        enable = true;
        enableOffloadCmd = true; # Provides `nvidia-offload`
      };

      # Make sure to use the correct Bus ID values for your system!
      # The values are obtained with `nix-shell -p lshw --run "sudo lshw -c display"`
      # but I feel like `lspci | grep -E 'VGA|3D'` is better
      # Then format `00:02.0` as "PCI:0:2:0" and `01:00.0` as "PCI:1:0:0"
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
