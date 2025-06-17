{
  pkgs,
  lib,
  settings,
  ...
}: let
  homeDir = settings.homeDir;
in {
  environment.systemPackages = [
    pkgs.vim
  ];

  nix.enable = true;
  users.users.harryp.home = lib.mkForce homeDir;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.zsh.enable = true; # default shell on catalina

  system = {
    primaryUser = "harryp";
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    stateVersion = 4;
    defaults = {
      dock = {
        mru-spaces = false;
        persistent-apps = [
          # todo
        ];
        autohide = true;
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
      };
      screencapture.location = "~/Pictures/screenshots";
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "uninstall";
    casks = [
      "1password"
      "calibre"
      "citrix-workspace"
      "docker"
      "dropbox"
      "firefox"
      "freecad"
      "ghostty"
      "jetbrains-toolbox"
      "libreoffice"
      "mullvadvpn"
      "obsidian"
      "protonmail-bridge"
      "rectangle"
      "rustdesk"
      "vlc"
      "whatsapp"
    ];
  };
}
