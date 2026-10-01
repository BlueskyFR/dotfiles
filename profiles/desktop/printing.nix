{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  services = {
    # Printing with printers
    printing = {
      enable = true;
      # CUPS Remote Printer Discovery daemon
      browsed.enable = true;
      drivers = with pkgs; [hplip];
    };

    # Printing also requires Avahi
    avahi = {
      enable = true;
      openFirewall = true;
      # Allow apps to query the Avahi daemon NSS (Name Service Switch),
      # which resolves the `.local` domain
      nssmdns4 = true;
    };
  };

  home-manager.users.hugo = {};
}
