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
      # Use a more recent nodejs version to have sqlite support for Github Copilot chat
      nodejsPackage = pkgs.nodejs_22;
    };

    cron.enable = true;
  };

  # Firewall
  ## Utility to view stateful active sessions in the conntrack module
  environment.systemPackages = with pkgs; [conntrack-tools];
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;
      backend = "nftables";
      allowPing = true;
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [5520];

      extraInputRules = ''
        ip saddr 10.0.0.0/24 ip protocol { tcp, udp } accept comment "Allow TCP/UDP from LAN"
      '';
    };
  };
}
