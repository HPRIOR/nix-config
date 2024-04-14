{
  config,
  pkgs,
  lib,
  inputs,
  userSettings,
  ...
}: let
  userName = userSettings.userName;
  homeDir = userSettings.homeDir;
  dotFiles = userSettings.dotFiles;
in {
  imports = [
    inputs.nix-colours.homeManagerModules.default
    ./shell
    ./neovim
    ./ui
    ./terminal
  ];
  colorScheme = inputs.nix-colours.colorSchemes.${userSettings.theme};

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };

  home.username = userName;
  home.homeDirectory = homeDir;
  home.stateVersion = "23.05";
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    ranger
    croc
    eza # ls replacement
    lazygit
    lazydocker
    difftastic
    bat # cat replacement
    du-dust # intuitive du - view drive space
    duf
    fd # find alternative
    ripgrep
    fzf
    choose # user friendly cut (and awk)
    jq # json processor
    sd # sed alternative
    tldr
    bottom
    glances
    hyperfine # benchmarking tool
    gping # ping with graph
    procs # ps alternative
    zoxide
    delta # git syntax highlighting pager
    kitty # terminal emulator
    firefox # applications
    cargo
    rustc
    rustfmt
    clippy
    gcc
    iftop
    aichat
    sops
    tree
    thefuck
    jetbrains.clion
    jetbrains.idea-ultimate
    jetbrains.rider
    pavucontrol
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = userSettings.fullName;
    userEmail = userSettings.email;
    extraConfig = {
      core.autocrlf = "input";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers decorations";
        whitespace-error-style = "22 reverse";
        navigate = "true";
      };
    };
  };

  home.file."${userSettings.configDir}/aichat/config.yaml".text = ''
    model: openai
    clients:
    - type: openai
  '';
}
