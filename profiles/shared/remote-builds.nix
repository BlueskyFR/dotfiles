{
  inputs,
  pkgs,
  lib,
  self,
  config,
  flakeDir,
  ...
}: {
  # Separate the options definition from our config below
  options = {
    is-remote-builder = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the current host is a remote builder itself.";
    };
  };

  config = {
    nix = {
      # Only distribute the builds if the machine is not a builder itself
      distributedBuilds = !config.is-remote-builder;
      buildMachines = lib.mkIf (!config.is-remote-builder) [
        {
          hostName = "hugooo.dev";
          systems = ["x86_64-linux"];
          protocol = "ssh-ng";
          maxJobs = 128;
          speedFactor = 2;

          sshUser = "remotebuild";
          # The expected pubkey of the builder, base64-encoded;
          ## get it with `base64 -w0 /etc/ssh/ssh_host_type_key.pub`
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUhzZktxcWoyL05IZ0J5dzI4OXd5bHRtclp0dWx0V2lRNlNQVkpDRCs3Qm4gcm9vdEB5dXJ0Cg==";
          # The private key to use to authenticate (passwordless) to the builder
          ## (should be a local fs path)
          sshKey = "${flakeDir}/profiles/remote-builder/remotebuild";

          supportedFeatures = ["big-parallel" "nixos-test" "benchmark" "kvm"];
        }
      ];

      # Use remote builders as binary caches too, speeds up additional builds
      ## i.e. make the builder fetch the dependencies itself rather than waiting for the host to upload them
      settings.builders-use-substitutes = true;
    };

    # Auto-accept our builder's fingerprint the first time
    programs.ssh.extraConfig = ''
      Host hugooo.dev
        StrictHostKeyChecking accept-new
    '';
  };
}
