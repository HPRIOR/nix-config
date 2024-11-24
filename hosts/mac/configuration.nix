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

  services.nix-daemon.enable = true;

  users.users.harryp.home = lib.mkForce homeDir;
  nix.settings.experimental-features = "nix-command flakes";

  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.zsh.enable = true; # default shell on catalina

  system = {
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
  nixpkgs.config.allowUnfree = true;
  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "uninstall";
    casks = [
      "firefox"
      "mullvadvpn"
      "whatsapp"
      "rectangle"
      "dropbox"
      "obsidian"
      "vlc"
      "libreoffice"
      "1password"
      "protonmail-bridge"
      "rustdesk"
      "citrix-workspace"
      "jetbrains-toolbox"
      "docker"
    ];
  };
}
