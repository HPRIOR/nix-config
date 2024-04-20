{
  pkgs,
  inputs,
  self,
  lib,
  settings,
  ...
}: {
  environment.systemPackages = [
    pkgs.vim
  ];

  services.nix-daemon.enable = true;

  users.users.harryp.home = lib.mkForce "/Users/harryp";
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true; # default shell on catalina

  # Set Git commit hash for darwin-version. Don't know the importance of this but it dooesn't seem to work.
  # Can't seem to pass in self from above
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  system = {
    stateVersion = 4;
    defaults = {
      dock = {
        persistent-apps = [
            # todo
        ];
        autohide = true;
        show-recents = false;
      };
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  # hosts/YourHostName/default.nix - inside the returning attribute set

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    # todo, check which are have packages available 
    casks = [
      "firefox"
      "1password"
      "syncthing"
      "mullvadvpn"
      "whatsapp"
      "rectangle"
      "protonmail-bridge"
      "dropbox"
      "discord"
      "docker"
      "obsidian"
      "vlc"
    ];
  };
}
