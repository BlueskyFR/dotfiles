{
  description = "My Nixos config flake using flake-parts!";

  inputs = {
    # Use stable channel by default
    # Difference between Nix channels: https://is.gd/2ySq2I
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/hugo/tmp/nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    # nixpkgs-stable.url = "/home/hugo/tmp/nixpkgs";

    home-manager = {
      # Make home-manager match our main NixOS version
      # url = "github:nix-community/home-manager/release-26.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    easy-hosts.url = "github:tgirlcloud/easy-hosts";

    hyprlock.url = "github:hyprwm/hyprlock";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      # FIXME: Using https://github.com/nix-community/nixos-vscode-server/pull/101 until merged;
      # fixes https://github.com/nix-community/nixos-vscode-server/issues/102
      url = "github:nix-community/nixos-vscode-server/79ada60decf3ff4bee4968f8b1136cb1846827a8";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    custom-fonts = {
      url = "github:BlueskyFR/fonts";
      # url = "/home/hugo/code/custom-fonts";
      # inputs.nixpkgs.follows = "nixpkgs";
      # inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-stable,
    flake-parts,
    easy-hosts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    /*
    (top@{config, withSystem, moduleWithSystem, ...}:
    */
    {
      imports = [
        easy-hosts.flakeModule
        flake-parts.flakeModules.easyOverlay
      ];

      # flake = {};

      systems = ["x86_64-linux"];

      easy-hosts = let
        desktop = ./profiles/desktop;
        personal = ./profiles/personal;
        gaming = ./profiles/gaming;
        work = ./profiles/work;
        server = ./profiles/server;
        remoteBuilder = ./profiles/remote-builder;
        zfs = ./profiles/zfs.nix;
        sddmGreeter = ./profiles/sddm-greeter.nix;
      in {
        shared = {
          modules = [
            # NixOS module, not a function �
            inputs.home-manager.nixosModules.home-manager

            # NixOS modules
            inputs.vscode-server.nixosModules.default

            ./profiles/shared

            # Custom overlay
            ./overlay
          ];
          specialArgs = {flakeDir = "/conf";};
        };

        hosts = {
          nzxt = {
            # arch = "x86_64"; (default)
            # class = "nixos"; (default; could be "iso")
            modules = [desktop sddmGreeter personal gaming];
            # nixpkgs = inputs.xxx;
            path = ./hosts/nzxt;
            # tags = [ "graphical" "desktop" ];
          };

          chador = {
            modules = [desktop sddmGreeter personal];
            path = ./hosts/chador;
          };

          yurt = {
            modules = [server zfs remoteBuilder];
            path = ./hosts/yurt;
          };

          # Work

          zbook = {
            modules = [desktop sddmGreeter work];
            path = ./hosts/zbook;
          };

          banana = {
            modules = [desktop sddmGreeter work];
            path = ./hosts/banana;
          };

          hcax = {
            modules = [server];
            path = ./hosts/hcax;
          };
        };
      };
    };
}
