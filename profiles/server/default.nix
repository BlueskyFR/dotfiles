{
  pkgs,
  lib,
  ...
}: {
  home-manager.users.hugo = {
    imports = [./containers.nix];

    # Override the default editor for servers to vim
    home.sessionVariables.EDITOR = lib.mkForce "vim";
  };

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      settings = {
        AllowTcpForwarding = "yes";
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    vscode-server = {
      enable = true;
      enableFHS = true;
      extraRuntimeDependencies = with pkgs; [
        # Classic tools
        git
        rustup
        # Nix
        nixd
        nil
        alejandra
        # Other required
        zlib
        openssl.dev
        pkg-config
      ];
    };

    cron.enable = true;
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
    # allowedUDPPorts = [ ... ];
  };
}
