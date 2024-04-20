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
    userSettings = rec {
      uid = 1000;
      userName = "harryp";
      homeDir = "/home/${userName}";
      dotFiles = "${homeDir}/.dotfiles";
      configDir = "${homeDir}/.config";
      fullName = "Harry Joseph Prior";
      email = "harryjosephprior@protonmail.com";
      extraGroups = ["networkmanager" "wheel"];
      theme = "kanagawa";
      font = "FiraCode Nerd Font Mono";
      fontPackage = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
    };
    systemSettings = {
      system = "x86_64-linux";
      networkHostName = "nixos";
      defaultLocale = "en_GB.UTF-8";
    };
    pkgs = nixpkgs.legacyPackages.${systemSettings.system};
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit (systemSettings) system;
        specialArgs = {
          inherit inputs;
          systemSettings = systemSettings;
          userSettings = userSettings;
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
              systemSettings = systemSettings;
              userSettings = userSettings;
            };
          }
        ];
      };
    };

    darwinConfigurations."Harrys-MacBook-Air" = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs;};

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
            systemSettings = systemSettings;
            userSettings = userSettings;
          };
        }
      ];
    };
  };
}
