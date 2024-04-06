{
  description = "System config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    sops-nix,
  } @ inputs: let
    lib = nixpkgs.lib;
    userSettings = {
      uid = 1000;
      userName = "harryp";
      fullName = "Harry Joseph Prior";
      email = "harryjosephprior@protonmail.com";
      extraGroups = ["networkmanager" "wheel"];
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
        modules = [./system/configuration.nix];
      };
    };

    homeConfigurations = {
      harryp = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          userSettings = userSettings;
        };
        modules = [
          ./user/home.nix
        ];
      };
    };
  };
}
