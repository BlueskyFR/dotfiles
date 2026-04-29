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
  is-remote-builder = lib.mkForce true; # Accessible elsewhere using `config.is-remote-builder`
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
