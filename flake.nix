{
	description = "System config";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nixvim = {
                url = "github:nix-community/nixvim";
                inputs.nixpkgs.follows = "nixpkgs";
        };
	};

	outputs = { self, nixpkgs, home-manager, nixvim }:
	let
		lib = nixpkgs.lib;
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
	in {
		
		nixosConfigurations = {
			nixos = lib.nixosSystem {
				inherit system;
				modules = [ ./system/configuration.nix ];

			};
		};

		homeConfigurations = {
			harryp = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
                extraSpecialArgs = {
                    inherit nixvim;
                };
				modules = [ 
                    ./user/home.nix 
                ];
			};
		};
	};
}
