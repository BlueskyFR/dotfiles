{
  inputs,
  pkgs,
  lib,
  self,
  config,
  flakeDir,
  ...
}: {
  # Custom setting to determine if the current system is a builder itself elsewhere
  # e.g. prevents on building remotely on itself ;)
  remote-builds.is-builder = lib.mkForce true;
  # Our remote build user needs to be trusted by the nix daemon
  ## (this gives root-like priviledges on the host thought!)
  nix.settings.trusted-users = ["remotebuild"];

  users = {
    users.remotebuild = {
      # Non-human service account
      isSystemUser = true;
      group = "remotebuild";
      useDefaultShell = true;

      # Allow our hosts to passwordlessly login
      openssh.authorizedKeys.keyFiles = [./remotebuild.pub];
      ## To specify the keys inline instead:
      # openssh.authorizedKeys.keys = [];
    };
    # Just create the group
    groups.remotebuild = {};
  };
}
