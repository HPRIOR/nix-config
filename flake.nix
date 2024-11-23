{
  description = "System config";
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-24.05";
    };

    ghostscript-fix = {
      url = "github:carlocab/nixpkgs/fix-ghostscript"; 
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colours.url = "github:Misterio77/nix-colors";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nix-colours,
    nix-darwin,
    nixpkgs,
    nixvim,
    fenix,
    sops-nix,
    ghostscript-fix,
  } @ inputs: let
    lib = nixpkgs.lib;
    sharedSettings = {
      homeDir,
      userName,
      hostName,
    }: {
      uid = 1000;
      userName = userName;
      homeDir = homeDir;
      hostName = hostName;
      dotFiles = "${homeDir}/.dotfiles";
      configDir = "${homeDir}/.config";
      fullName = "Harry Prior";
      email = "harjp@pm.me";
      theme = "kanagawa";
      font = "FiraCode Nerd Font Mono";
      fontSize = 12;
      extraGroups = ["networkmanager" "wheel" "docker"];
    };
  in {
    nixosConfigurations = let
      system = "x86_64-linux";
      userName = "harryp";
      homeDir = "/home/${userName}";
      hostName = "nixos";
      settings = sharedSettings {
        userName = userName;
        homeDir = homeDir;
        hostName = hostName;
      };
      linuxSettings = {
        primaryMonitor = "HDMI-A-1";
      };
    in {
      nixos = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          settings = settings;
        };
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (import ./overlays/citrix.nix)
              fenix.overlays.default
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.harryp.imports = [./hosts/desktop/home.nix];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              settings = settings;
              linuxSettings = linuxSettings;
            };
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };

      work = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          settings = settings;
        };
        modules = [
          ./hosts/work/configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (import ./overlays/citrix.nix)
              fenix.overlays.default
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.harryp.imports = [./hosts/work/home.nix];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              settings = settings;
              linuxSettings = linuxSettings;
            };
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };
    };

    darwinConfigurations = let
      system = "aarch64-darwin";
      userName = "harryp";
      homeDir = "/Users/${userName}";
      hostName = "Harrys-MacBook-Air";
      settings = sharedSettings {
        userName = userName;
        homeDir = homeDir;
        hostName = hostName;
      };
    in {
      "Harrys-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          settings = settings;
        };

        modules = [
          ./hosts/air/configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              fenix.overlays.default
              (final: prev: {
                ghostscript = ghostscript-fix.legacyPackages.${prev.system}.ghostscript;
              })
            ];
            # users.users.harryp.home = "/Users/harryp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.harryp.imports = [./hosts/air/home.nix];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              settings = settings;
            };
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };

      "Harrys-MacBook-Air" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          settings = settings;
        };

        modules = [
          ./hosts/air/configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              fenix.overlays.default
            ];
            # users.users.harryp.home = "/Users/harryp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.harryp.imports = [./hosts/air/home.nix];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              settings = settings;
            };
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
        ];
      };
    };
  };
}
