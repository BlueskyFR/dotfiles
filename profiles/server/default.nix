{
  pkgs,
  lib,
  ...
}: {
  imports = [./containers.nix];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      AllowTcpForwarding = "yes";
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.vscode-server = {
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

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
    # allowedUDPPorts = [ ... ];
  };
}
