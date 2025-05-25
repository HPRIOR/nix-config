{
  description = "System config";
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-25.05";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
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

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    mkSystem = import ./utils/mkSystem.nix {
      inputs = inputs;
      nixpkgs = nixpkgs;
    };
  in {
    nixosConfigurations = {
      nixos = mkSystem.nixos {
        system = "x86_64-linux";
        sysConfig = ./hosts/desktop/configuration.nix;
        homeConfig = ./hosts/desktop/home.nix;
      };
    };

    darwinConfigurations = let
      system = "aarch64-darwin";
      macConfig = ./hosts/mac/configuration.nix;
      macHomeConfig = ./hosts/mac/home.nix;
    in {
      "Harrys-MacBook-Pro" = mkSystem.darwin {
        system = system;
        hostNameArg = "Harrys-MacBook-Pro";
        sysConfig = macConfig;
        homeConfig = macHomeConfig;
      };
      "Harrys-MacBook-Air" = mkSystem.darwin {
        system = system;
        hostNameArg = "Harrys-MacBook-Air";
        sysConfig = macConfig;
        homeConfig = macHomeConfig;
      };
    };
  };
}
