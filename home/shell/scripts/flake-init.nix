let
  base = ''
    {
      inputs = {
        nixpkgs.url = \"github:NixOS/nixpkgs/nixos-unstable\";
        flake-utils.url = \"github:numtide/flake-utils\";
      };
      outputs = {
        self,
        nixpkgs,
        flake-utils
      }:
        flake-utils.lib.eachDefaultSystem
        (
          system: let
            pkgs = import nixpkgs {
              inherit system;
            };
          in
            with pkgs; {
              devShells.default = mkShell {
                buildInputs = [];
              };
            }
        );
    }
  '';

  dotnet = ''
    {
        inputs = {
            nixpkgs.url = \"github:NixOS/nixpkgs/nixos-unstable\";
            flake-utils.url = \"github:numtide/flake-utils\";
        };
        outputs = {
            self,
            nixpkgs,
            flake-utils,
        }:
            flake-utils.lib.eachDefaultSystem
            (
            system: let
                pkgs = import nixpkgs {
                inherit system;
                };
            in
                with pkgs; {
                devShells.default = mkShell {
                    buildInputs = [
                    dotnetCorePackages.sdk_9_0
                    ];
                    DOTNET_ROOT = \"$${pkgs.dotnetCorePackages.sdk_9_0}\";
                };
                }
            );
    }
  '';

  rust = ''
    {
      inputs = {
        nixpkgs.url = \"github:NixOS/nixpkgs/nixos-unstable\";
        flake-utils.url = \"github:numtide/flake-utils\";
        rust-overlay = {
          url = \"github:oxalica/rust-overlay\";
          inputs = {
            nixpkgs.follows = \"nixpkgs\";
            flake-utils.follows = \"flake-utils\";
          };
        };
      };
      outputs = {
        self,
        nixpkgs,
        flake-utils,
        rust-overlay,
      }:
        flake-utils.lib.eachDefaultSystem
        (
          system: let
            overlays = [(import rust-overlay)];
            pkgs = import nixpkgs {
              inherit system overlays;
            };
            darwinDeps =
              if pkgs.stdenv.isDarwin
              then
                with pkgs.darwin.apple_sdk.frameworks; []
              else [];
            linuxDeps = with pkgs;
              if stdenv.isLinux
              then []
              else [];
          in {
            devShells.default = pkgs.mkShell rec {
              buildInputs =
                [
                  (pkgs.rust-bin.stable.latest.default.override {extensions = [\"rust-src\" \"cargo\" \"rustc\" \"rust-analyzer\"];})
                  pkgs.rustup
                ]
                ++ darwinDeps
                ++ linuxDeps;
            };
          }
        );
    }
  '';

  direnv-init = let
    dirEnvTemplate = ''
      if ! has nix_direnv_version || ! nix_direnv_version 3.0.4; then
          source_url \"https://raw.githubusercontent.com/nix-community/nix-direnv/3.0.4/direnvrc\" \"sha256-DzlYZ33mWF/Gs8DDeyjr8mnVmQGx7ASYqA5WlxwvBG4=\"
      fi
      use flake'';
  in "echo \"${dirEnvTemplate}\" > .envrc";

  flake-init = flake: "echo \"${flake}\" > flake.nix && echo '.direnv' >> .gitignore  && ${direnv-init} && git add flake.nix .envrc && direnv allow";
in {
  flake-init = flake-init base;
  rust-init = flake-init rust;
  dotnet-init = flake-init dotnet;
}
