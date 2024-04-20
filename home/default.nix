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

    xdg = lib.mkIf isLinux {
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
        firefox # applications
        pavucontrol
      ]);

    # home.activation = lib.mkIf isDarwin {
    #   # This should be removed once
    #   # https://github.com/nix-community/home-manager/issues/1341 is closed.
    #   aliasApplications = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     app_folder="$(echo ~/Applications)/Home Manager Apps"
    #     home_manager_app_folder="$genProfilePath/home-path/Applications"
    #     $DRY_RUN_CMD rm -rf "$app_folder"
    #     # NB: aliasing ".../home-path/Applications" to "~/Applications/Home Manager Apps" doesn't
    #     #     work (presumably because the individual apps are symlinked in that directory, not
    #     #     aliased). So this makes "Home Manager Apps" a normal directory and then aliases each
    #     #     application into there directly from its location in the nix store.
    #     $DRY_RUN_CMD mkdir "$app_folder"
    #     for app in $(find "$newGenPath/home-path/Applications" -type l -exec readlink -f {} \;)
    #     do
    #       $DRY_RUN_CMD osascript \
    #         -e "tell app \"Finder\"" \
    #         -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$app\"" \
    #         -e "set name of result to \"$(basename $app)\"" \
    #         -e "end tell"
    #     done
    #   '';
    # };

    # home.activation = {
    #   aliasHomeManagerApplications = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     app_folder="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
    #     rm -rf "$app_folder"
    #     mkdir -p "$app_folder"
    #     find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
    #         app_target="$app_folder/$(basename "$app")"
    #         real_app="$(readlink "$app")"
    #         echo "mkalias \"$real_app\" \"$app_target\"" >&2
    #         $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
    #     done
    #   '';
    # };

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
