{
  description = "My Nixos config flake using flake-parts!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/hugo/code/nixpkgs";
    # Difference between Nix channels: https://is.gd/2ySq2I
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    easy-hosts.url = "github:tgirlcloud/easy-hosts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom-hyprlock.url = "github:BlueskyFR/hyprlock";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom-fonts = {
      url = "github:BlueskyFR/fonts";
      # url = "/home/hugo/code/custom-fonts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
        work = ./profiles/work;
        server = ./profiles/server;
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
            modules = [desktop sddmGreeter personal];
            # nixpkgs = inputs.xxx;
            path = ./hosts/nzxt;
            # tags = [ "graphical" "desktop" ];
          };

          chador = {
            modules = [desktop sddmGreeter personal];
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

  /*
  outputs = inputs @ {
    self,
    nixpkgs,
    # nixpkgs-stable,
    home-manager,
    utils,
    chaotic,
    ...
  }: let
    flakeDir = "/conf";
    nixpkgs-stable = inputs.nixpkgs-stable.x86_64-linux.nixpkgs;
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

        extraArgs = {inherit nixpkgs-stable inputs flakeDir;};
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
