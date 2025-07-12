# utils/mkSystem.nix
{
  inputs,
  nixpkgs,
}: let
  # helper: build a pkgs instance once and share it with both OS and HM
  mkPkgs = {
    system,
    extraOverlays ? [],
  }: let
    unstable = import inputs.unstable {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };
    # overlays that should be on every system
    sharedOverlays = [
      inputs.fenix.overlays.default
      (import ../overlays/nixvim-avante.nix {unstable = unstable;})
      (import ../overlays/claude.nix {unstable = unstable;})
    ];

    permittedInsecurePkgs = [];
  in
    import nixpkgs {
      inherit system;
      overlays = extraOverlays ++ sharedOverlays;
      config.permittedInsecurePackages = permittedInsecurePkgs;

      config = {
        allowUnfree = true;
      };
    };

  # helper: common user metadata injected into modules via `settings`
  sharedUserName = "harryp";
  sharedSettings = {
    userName,
    homeDir,
    hostName,
  }: {
    uid = 1000;
    userName = userName;
    homeDir = homeDir;
    hostName = hostName;
    dotFiles = "${homeDir}/.nix-config";
    configDir = "${homeDir}/.config";
    fullName = "Harry Prior";
    email = "harjp@pm.me";
    theme = "kanagawa";
    font = "FiraCode Nerd Font Mono";
    fontSize = 12;
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
in {
  nixos = {
    system,
    sysConfig,
    homeConfig,
  }: let
    pkgs = mkPkgs {
      inherit system;
      # overlays needed only on Linux
      extraOverlays = [
        (import ../overlays/citrix.nix)
        inputs.ghostty.overlays.default
      ];
    };

    settings = sharedSettings rec {
      userName = sharedUserName;
      homeDir = "/home/${userName}";
      hostName = "nixos";
    };
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system pkgs; # <= share pkgs with Home-Manager
      specialArgs = {
        inherit inputs settings;
      };

      modules = [
        sysConfig
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${sharedUserName}.imports = [homeConfig];

          home-manager.extraSpecialArgs = {
            inherit inputs settings;
            linuxSettings = {primaryMonitor = "HDMI-A-1";};
          };

          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        }
      ];
    };

  darwin = {
    system,
    hostNameArg,
    sysConfig,
    homeConfig,
  }: let
    pkgs = mkPkgs {inherit system;}; # no extra overlays on macOS

    settings = sharedSettings rec {
      userName = sharedUserName;
      homeDir = "/Users/${userName}";
      hostName = hostNameArg;
    };
  in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system pkgs;
      specialArgs = {
        inherit inputs settings;
      };

      modules = [
        sysConfig
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${sharedUserName}.imports = [homeConfig];

          home-manager.extraSpecialArgs = {
            inherit inputs settings;
          };

          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
            inputs.mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };
}
