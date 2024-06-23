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
  configDir = settings.configDir;

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    inputs.nix-colours.homeManagerModules.default
    ./shell
    ./vim
    ./terminal
    ./mac
    ./ranger/default.nix
  ];

  options = {
  };

  config = {
    systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
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
          "text/html" = ["firefox.desktop"];
          "x-scheme-handler/http" = ["firefox.desktop"];
          "x-scheme-handler/https" = ["firefox.desktop"];
          "x-scheme-handler/about" = ["firefox.desktop"];
          "x-scheme-handler/unknown" = ["firefox.desktop"];
        };
        associations.added = {
          "text/html" = ["firefox.desktop"];
          "x-scheme-handler/http" = ["firefox.desktop"];
          "x-scheme-handler/https" = ["firefox.desktop"];
          "x-scheme-handler/about" = ["firefox.desktop"];
          "x-scheme-handler/unknown" = ["firefox.desktop"];
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
        aichat
        atool
        bat # cat replacement
        bottom
        choose # user friendly cut (and awk)
        croc
        ctop
        delta # git syntax highlighting pager
        difftastic
        discord
        du-dust # intuitive du - view drive space
        duf
        eva
        eza # ls replacement
        fd # find alternative
        fzf
        glances
        gping # ping with graph
        hexyl
        hurl
        hyperfine # benchmarking tool
        iftop
        inetutils
        jq # json processor
        kitty # terminal emulator
        lazydocker
        lazygit
        lsof
        mosh
        procs # ps alternative
        ranger
        ripgrep
        sd # sed alternative
        sops
        spotify
        syncthing
        thefuck
        tldr
        tree
        unzip
        watchexec
        zathura
        zoom-us
        zoxide
      ]
      ++ (lib.optionals isLinux [
        _1password
        _1password-gui
        # Download tarbal from citrix then run nix-prefetch-url file:///pathtofile
        # Some declarative prerequisites for this package
        citrix_workspace
        feh
        firefox # applications
        glibc
        grim
        jetbrains-toolbox
        libreoffice
        libtree
        nfs-utils
        obsidian
        papirus-icon-theme
        pavucontrol
        protonmail-bridge
        rustdesk
        slurp
        strace
        v4l-utils
        vlc
      ]);

    services.syncthing = {
      enable = true;
      # tray.enable = isLinux; ## not working for some reason
    };

    #  https://github.com/nix-community/home-manager/issues/1341 is closed.
    # creates aliases to nix store so that spotlight can search for nix installed packages
    # need to fix this so a check is done against $genProfilePath/home-path/Applications before executing
    home.activation = lib.mkIf isDarwin {
      aliasHomeManagerApplications = lib.hm.dag.entryAfter ["writeBoundary"] ''
        app_folder="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
        rm -rf "$app_folder"
        mkdir -p "$app_folder"
        find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
            app_target="$app_folder/$(basename "$app")"
            real_app="$(readlink "$app")"
            echo "mkalias \"$real_app\" \"$app_target\"" >&2
            $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
        done
      '';
    };

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
        init.defaultBranch = "main";
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

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        # Private key generated using ssh and `nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt`
        keyFile = "/etc/sops/age/keys.txt";
      };
      secrets.gpt-api-key = {};
      secrets.server-ip = {};
    };

    home.file."${settings.configDir}/aichat/config.yaml".text = ''
      model: openai
      clients:
      - type: openai
    '';

    home.sessionVariables = {
      DEFAULT_BROWSER =
        if isLinux
        then "${pkgs.firefox}/bin/firefox"
        else "default";

      AICHAT_CONFIG_DIR = "${settings.configDir}/aichat";
      OPENAI_API_KEY = "$(cat ${config.sops.secrets.gpt-api-key.path})";
      EDITOR = "nvim";
      PAGER = "bat --paging always";
    };

    services.dropbox = {
      path = lib.mkIf isLinux /home/harryp/Dropbox;
      enable = isLinux;
    };
  };
}
