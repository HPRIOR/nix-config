{
  config,
  pkgs,
  lib,
  inputs,
  settings,
  ...
}: let
  userName = settings.userName;
  homeDir = settings.homeDir;
  dotFiles = settings.dotFiles;

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    inputs.nix-colours.homeManagerModules.default
    ./shell
    ./neovim
    ./terminal
    ./ui
  ];

  options = {
  };

  config = {
    colorScheme = inputs.nix-colours.colorSchemes.${settings.theme};

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

    home.packages = with pkgs;
      [
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
      ]
      ++ (lib.optionals isLinux [
        pavucontrol
      ]);

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = settings.fullName;
      userEmail = settings.email;
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

    home.file."${settings.configDir}/aichat/config.yaml".text = ''
      model: openai
      clients:
      - type: openai
    '';
  };
}
