{
  config,
  pkgs,
  lib,
  ...
}: {
  services = {
  };

  # environment.systemPackages = with pkgs; [];

  boot = {
    # Automatically use the latest ZFS-compatible Linux kernel
    kernelPackages = let
      zfsCompatibleKernelPackages =
        lib.filterAttrs (
          name: kernelPackages:
            (builtins.match "linux_[0-9]+_[0-9]+" name)
            != null
            && (builtins.tryEval kernelPackages).success
            && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
        )
        pkgs.linuxKernel.packages;
      latestKernelPackage = lib.last (
        lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
          builtins.attrValues zfsCompatibleKernelPackages
        )
      );
    in
      lib.mkForce latestKernelPackage;

    supportedFilesystems = ["zfs"];

    zfs = {
      # Will be false by default after 26.11
      forceImportRoot = false;

      # Import the pool at boot
      extraPools = ["tank"];
    };
  };

  services = {
    zfs = {
      # Weekly automatic scrubbing (checks and repairs corruption), once per month (default)
      autoScrub.enable = true;

      # Let SSDs know which blocks are now free so they can do their own business, harmless for HDDs, once per week (default)
      trim.enable = true;

      # Automatically take snapshots to be able to rollback e.g. in case of unintended deletion of files
      autoSnapshot = {
        # Important: only datasets with the com.sun:auto-snapshot property set to true will be snapshotted (see https://github.com/bdrewery/zfstools#dataset-setup):
        # `zfs set com.sun:auto-snapshot=true DATASET`
        # - Check list of volumes to backup: `zfs get all | g sun`
        # - List snapshots: `zfs list -t snapshot`
        # - View space used by snapshots: `zfs get usedbysnapshots`
        # - View space used for everything at one: `zfs list -o space,reservation,refreservation -t all -r`
        enable = true;
        frequent = 4; # 15 min interval
        hourly = 24;
        daily = 5;
        weekly = 3;
        monthly = 3;
      };
    };

    # NFS shares export;
    # export a share with e.g. `sudo zfs set sharenfs="ro=10.0.0.0/24" DATASET`
    nfs.server.enable = true;
  };
}
