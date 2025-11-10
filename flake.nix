{
  description = "My Nixos config flake using flake-parts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/hugo/code/nixpkgs";
    # Difference between Nix channels: https://is.gd/2ySq2I
    # stable-pkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    easy-hosts.url = "github:tgirlcloud/easy-hosts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
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
        server = ./profiles/server;
        sddmGreeter = ./profiles/sddm-greeter.nix;
      in {
        shared = {
          modules = [
            # NixOS module, not a function �
            inputs.home-manager.nixosModules.home-manager

            inputs.chaotic.nixosModules.default
            inputs.vscode-server.nixosModules.default

            ./profiles/shared

            # Custom overlay
            {
              nixpkgs.overlays = [(import ./overlay.nix)];
            }
          ];
          specialArgs = {flakeDir = "/conf";};
        };

        hosts = {
          nzxt = {
            # arch = "x86_64"; (default)
            # class = "nixos"; (default; could be "iso")
            modules = [desktop sddmGreeter];
            # nixpkgs = inputs.xxx;
            path = ./hosts/nzxt;
            # tags = [ "graphical" "desktop" ];
          };

          chador = {
            modules = [desktop];
            path = ./hosts/chador;
          };

          yurt = {
            modules = [server];
            path = ./hosts/yurt;
          };

          # Work

          zbook = {
            modules = [desktop];
            path = ./hosts/zbook;
          };

          hcax = {
            modules = [server];
            path = ./hosts/hcax;
          };
        };
      };
    };

  /*
  outputs = inputs @ {
    self,
    nixpkgs,
    # stable-pkgs,
    home-manager,
    utils,
    chaotic,
    ...
  }: let
    flakeDir = "/conf";
    stable-pkgs = inputs.stable-pkgs.x86_64-linux.nixpkgs;
  in
    utils.lib.mkFlake {
      # Required arguments
      inherit self inputs;

      # Shared configuration between all channels
      channelsConfig = {allowUnfree = true;};

      # Overlays applied to all channels
      sharedOverlays = [
        (import ./overlays.nix)
      ];

      hostDefaults = {
        # Default architecture
        system = "x86_64-linux";

        modules = [
          ./options.nix
          ./profiles/shared

          # NixOS module, not a function �
          home-manager.nixosModules.home-manager

          chaotic.nixosModules.default
        ];

        extraArgs = {inherit stable-pkgs inputs flakeDir;};
      };

      hosts = let
        desktop = ./profiles/desktop;
        server = ./profiles/server.nix;
      in {
        nzxt.modules = [
          desktop
          ./hosts/nzxt
        ];

        chador.modules = [
          desktop
          ./hosts/chador
        ];

        Yurt.modules = [
          server
        ];

        Banana.modules = [
          desktop
        ];
      };
    };

  #let
  #  system = "x86_64-linux";
  #  pkgs = nixpkgs.legacyPackages.${system};
  #in {
  #  # TODO: add https://is.gd/FPd0jn
  #  # system.nixos.label = concatStringsSep "-" ((sort (x: y: x < y) cfg.tags) ++ [ "${cfg.version}.${self.sourceInfo.shortRev or "dirty"}" ]);
  #  nixosConfigurations.default = nixpkgs.lib.nixosSystem {
  #    specialArgs = {inherit inputs system;};
  #    modules = [
  #      ./configuration.nix
  #
  #      home-manager.nixosModules.home-manager
  #      {
  #        home-manager.useGlobalPkgs = true;
  #        home-manager.useUserPackages = true;
  #        home-manager.users.hugo = import ./home.nix;
  #      }
  #    ];
  #  };
  #};
  */
}
