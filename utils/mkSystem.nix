{
  inputs,
  nixpkgs,
}: let
  home-manager = inputs.home-manager;
  lib = nixpkgs.lib;
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

  permittedInsecurePkgs = [
    "dotnet-core-combined"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-7.0.410"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-wrapped-combined"
    "dotnet-combined"
    "dotnet-sdk-wrapped-7.0.410"
  ];

  sharedOverlays = [
    inputs.fenix.overlays.default
  ];
in {
  nixos = {
    system,
    sysConfig,
    homeConfig,
  }: let
    settings = sharedSettings rec {
      userName = sharedUserName;
      homeDir = "/home/${userName}";
      hostName = "nixos";
    };
  in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        settings = settings;
      };
      modules = [
        sysConfig
        home-manager.nixosModules.home-manager
        {
          nixpkgs.config.permittedInsecurePackages = permittedInsecurePkgs;
          nixpkgs.overlays =
            [
              (import ../overlays/citrix.nix)
              (inputs.ghostty.overlays.default)
            ]
            ++ sharedOverlays;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.harryp.imports = [homeConfig];
          home-manager.extraSpecialArgs = {
            inherit inputs;
            settings = settings;
            linuxSettings = {
              primaryMonitor = "HDMI-A-1";
            };
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
    settings = sharedSettings rec {
      userName = sharedUserName;
      homeDir = "/Users/${userName}";
      hostName = hostNameArg;
    };
  in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        settings = settings;
      };

      modules = [
        sysConfig
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.home-manager
        {
          nixpkgs.config.permittedInsecurePackages = permittedInsecurePkgs;
          nixpkgs.overlays = [] ++ sharedOverlays;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.harryp.imports = [homeConfig];
          home-manager.extraSpecialArgs = {
            inherit inputs;
            settings = settings;
          };
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
            inputs.mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };
}
