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
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;

  rust-packages = rec {
    toolchain-version = "stable";
    toolchain = pkgs.fenix.${toolchain-version}.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ];
    analyzer = pkgs.fenix.${toolchain-version}.rust-analyzer;
    src = pkgs.fenix.${toolchain-version}.rust-src;
    cargo = pkgs.fenix.${toolchain-version}.cargo;
    rustc = pkgs.fenix.${toolchain-version}.rustc;
  };
in {
  imports = [
    inputs.nix-colours.homeManagerModules.default
    ./shell
    (import ./vim {
      inherit pkgs inputs settings;
      rust-packages = rust-packages;
    })
    ./terminal
    ./ui
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
        get_iplayer
        glances
        glow
        gping # ping with graph
        hexyl
        hurl
        hyperfine # benchmarking tool
        iftop
        inetutils
        jless
        jq # json processor
        kitty # terminal emulator
        lazydocker
        lazygit
        lsof
        mosh
        perl538Packages.vidir
        procs # ps alternative
        progress
        ranger
        ripgrep
        rust-packages.analyzer
        rust-packages.toolchain
        sd # sed alternative
        sops
        spotify
        syncthing
        tetex
        texstudio
        thefuck
        tldr
        tree
        # build failing - investigate
        # qsv
        unzip
        watchexec
        zathura
        zoxide
      ]
      ++ (lib.optionals isLinux [
        (zoom-us.overrideAttrs (oldAttrs: let
        in rec {
          version = "6.0.12.5501";
          src = pkgs.fetchurl {
            url = "https://zoom.us/client/${version}/zoom_x86_64.pkg.tar.xz";
            sha256 = "sha256-h9gjVd7xqChaoC2BZWEhR5WdyfQrPiBjM2WHXMgp8uQ=";
          };
        }))
        _1password-cli
        _1password-gui
        calibre
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
        # rustdesk ## -- broken
        slurp
        strace
        v4l-utils
        vlc
        # see https://github.com/ghostty-org/ghostty/discussions/3224#discussioncomment-11711871 - high iowait usage otherwise, waiting for fix
        inputs.ghostty.packages.${pkgs.system}.default
      ])
      ++ (lib.optionals isDarwin [zoom-us]);

    services.syncthing = {
      enable = true;
      # tray.enable = isLinux; ## not working for some reason
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
        push.autoSetupRemote = true;
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

    programs.atuin = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      enableNushellIntegration = false;
      settings = {
        key_path = config.sops.secrets.atuin-key.path;
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "http://192.168.100.60:8888";
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
      secrets.claude_key = {};
      secrets.sops-age-path = {};
      secrets.atuin-key = {};
    };

    home.file."${settings.configDir}/aichat/config.yaml".text = ''
      model: openai
      clients:
      - type: openai
    '';

    home.file."${settings.homeDir}/Code/.stignore".text = ''
      !**/.envrc
      !**/.direnv
      !**/.git
      !**/.gitignore
      !**/.ocamlformat
      // ignore all hidden files, except for the above
      (?d)**/.*

      // mac
      (?d).DS_Store

      // Dotnet
      (?d)**/obj/
      (?d)**/bin/
      (?d)**/node_modules/

      // Ocaml
      (?d)**/_build/
      (?d)**/_opam/

      // Rust
      (?d)**/target/
      // (?d)Cargo.lock
      (?d)**/*.rs.bk

      (?d)**/venv/
      (?d)**/.idea/

      // Scala
      (?d)**/.metals
      (?d)**/.bloop

      // Android
      (?d)**/.android
    '';

    home.sessionVariables = {
      DEFAULT_BROWSER =
        if isLinux
        then "${pkgs.firefox}/bin/firefox"
        else "default";

      AICHAT_CONFIG_DIR = "${settings.configDir}/aichat";
      OPENAI_API_KEY = "$(cat ${config.sops.secrets.gpt-api-key.path})";
      ANTHROPIC_API_KEY = "$(cat ${config.sops.secrets.claude_key.path})";
      EDITOR = "nvim";
      PAGER = "bat --paging always";
      RUST_SRC_PATH = "${rust-packages.src}/lib/rustlib/src/rust/library";
      SOPS_AGE_KEY_FILE = "$(cat ${config.sops.secrets.sops-age-path.path})";
    };

    services.dropbox = {
      path = lib.mkIf isLinux /home/harryp/Dropbox;
      enable = isLinux;
    };
  };
}
