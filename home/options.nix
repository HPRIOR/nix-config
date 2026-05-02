{
  lib,
  settings,
  ...
}: let
  defaultProfile = settings.profile or "full";
in {
  options.my = {
    identity = {
      uid = lib.mkOption {
        type = lib.types.int;
        default = settings.uid;
      };
      userName = lib.mkOption {
        type = lib.types.str;
        default = settings.userName;
      };
      homeDir = lib.mkOption {
        type = lib.types.str;
        default = settings.homeDir;
      };
      fullName = lib.mkOption {
        type = lib.types.str;
        default = settings.fullName;
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = settings.email;
      };
    };

    paths = {
      dotFiles = lib.mkOption {
        type = lib.types.str;
        default = settings.dotFiles;
      };
      configDir = lib.mkOption {
        type = lib.types.str;
        default = settings.configDir;
      };
    };

    appearance = {
      theme = lib.mkOption {
        type = lib.types.str;
        default = settings.theme;
      };
      font = lib.mkOption {
        type = lib.types.str;
        default = settings.font;
      };
      fontSize = lib.mkOption {
        type = lib.types.int;
        default = settings.fontSize;
      };
    };

    keyboard = {
      remapCapsToEscape = lib.mkOption {
        type = lib.types.bool;
        default = settings.keyboard.remapCapsToEscape or false;
      };
    };

    profile = lib.mkOption {
      type = lib.types.enum ["minimal" "full" "workstation"];
      default = defaultProfile;
    };

    features = {
      largePackages.enable = lib.mkEnableOption "large desktop applications";
      aiTools.enable = lib.mkEnableOption "AI CLI tools and generated config";
      atuin.enable = lib.mkEnableOption "Atuin shell history sync";
      codeSyncFiles.enable = lib.mkEnableOption "generated project sync ignore files";
      dropbox.enable = lib.mkEnableOption "Dropbox";
      ghostty.enable = lib.mkEnableOption "Ghostty terminal config";
      git.enable = lib.mkEnableOption "Git configuration";
      homeManager.enable = lib.mkEnableOption "Home Manager self-management";
      neovim.enable = lib.mkEnableOption "Neovim via nixvim";
      shell.enable = lib.mkEnableOption "interactive shell configuration";
      syncthing.enable = lib.mkEnableOption "Syncthing";
      yazi.enable = lib.mkEnableOption "Yazi file manager";

      desktop = {
        enable = lib.mkEnableOption "Linux desktop user configuration";
        hyprland.enable = lib.mkEnableOption "Hyprland user configuration";
        noctalia.enable = lib.mkEnableOption "Noctalia shell";
        notifications.enable = lib.mkEnableOption "desktop notifications";
        rofi.enable = lib.mkEnableOption "Rofi launcher config";
      };

      darwin = {
        enable = lib.mkEnableOption "Darwin user configuration";
        rectangle.enable = lib.mkEnableOption "Rectangle window manager config";
      };
    };
  };

  config = {
    my.features = {
      aiTools.enable = lib.mkDefault true;
      atuin.enable = lib.mkDefault true;
      codeSyncFiles.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      homeManager.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
      syncthing.enable = lib.mkDefault true;
      yazi.enable = lib.mkDefault true;
      largePackages.enable = lib.mkDefault (defaultProfile != "minimal");
    };
  };
}
