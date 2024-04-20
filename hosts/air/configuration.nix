{
  pkgs,
  self,
  ...
}: {
  environment.systemPackages = [
    pkgs.vim
  ];

  # services.nix-daemon.enable = true;

  # users.users.harryp.home = "/Users/harryp";
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true; # default shell on catalina

  # Set Git commit hash for darwin-version. Don't know the importance of this but it dooesn't seem to work.
  # Can't seem to pass in self from above
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 4;

  nixpkgs.hostPlatform = "aarch64-darwin";
  # hosts/YourHostName/default.nix - inside the returning attribute set

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    casks = [];
  };
}
