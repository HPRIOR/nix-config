{
  description = "System config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colours.url = "github:Misterio77/nix-colors";
  };

  outputs = {
    self,
    home-manager,
    nix-colours,
    nix-darwin,
    nixpkgs,
    nixvim,
    sops-nix,
  } @ inputs: let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = let
      system = "x86_64-linux";
      settings = rec {
        uid = 1000;
        hostName = "nixos";
        userName = "harryp";
        homeDir = "/home/${userName}";
        dotFiles = "${homeDir}/.dotfiles";
        configDir = "${homeDir}/.config";
        fullName = "Harry Joseph Prior";
        email = "harryjosephprior@protonmail.com";
        extraGroups = ["networkmanager" "wheel"];
        theme = "kanagawa";
        font = "FiraCode Nerd Font Mono";
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
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.harryp.imports = [./hosts/desktop/home.nix];
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

    darwinConfigurations = let
      system = "aarch64-darwin";
      settings = rec {
        uid = 1000;
        userName = "harryp";
        homeDir = "/Users/${userName}";
        dotFiles = "${homeDir}/.dotfiles";
        configDir = "${homeDir}/.config";
        fullName = "Harry Joseph Prior";
        email = "harryjosephprior@protonmail.com";
        extraGroups = ["networkmanager" "wheel"];
        theme = "kanagawa";
        font = "FiraCode Nerd Font Mono";
      };
    in {
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
