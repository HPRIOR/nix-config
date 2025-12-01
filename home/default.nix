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
in {
  imports = [
    inputs.nix-colours.homeManagerModules.default
    ./shell
    (import ./vim {
      inherit pkgs inputs settings config;
    })
    ./terminal
    ./ui
    ./mac
  ];

  options = {
  };

  config = {
    systemd.user.services.mbsync.unitConfig.After = ["sops-nix.service"];
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

    home.packages = with pkgs;
      [
        aichat
        atool
        bat # cat replacement
        bottom
        choose # user friendly cut (and awk)
        claude-code
        codex
        croc
        ctop
        delta # git syntax highlighting pager
        difftastic
        discord
        dust # intuitive du - view drive space
        duf
        eva
        eza # ls replacement
        fd # find alternative
        fzf
        get_iplayer
        glances
        glow
        gping # ping with graph
        gh
        hexyl
        hurl
        hyperfine # benchmarking tool
        immich-cli
        iftop
        inetutils
        jless
        jq # json processor
        kitty # terminal emulator
        lazydocker
        lazygit
        lsof
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        mosh
        perl538Packages.vidir
        procs # ps alternative
        progress
        ripgrep
        sd # sed alternative
        sops
        spotify
        syncthing
        tetex
        texstudio
        pay-respects
        tldr
        tree
        # build failing - investigate
        # qsv
        unzip
        watchexec
        yazi
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
        # Some prerequisites for this package
        # Download tarbal from citrix then run nix-prefetch-url file:///pathtofile
        # citrix_workspace
        feh
        firefox # applications
        freecad
        glibc
        grim
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
        # see https://github.com/ghostty-org/ghostty/discussions/3224#discussioncomment-11711871 - high iowait usage otherwise, waiting for fix
        inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
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
      package = pkgs.gitFull;
      settings = {
        user.name = settings.fullName;
        user.email = settings.email;
        core.autocrlf = "input";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        alias.lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "side-by-side line-numbers decorations";
        whitespace-error-style = "22 reverse";
        navigate = "true";
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
      !**/.claude
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
      (?d)**/.opam/
      (?d)**/.opam-switch/

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

    home.file."${settings.homeDir}/.claude/commands/fix-github-issue.md".text = ''
      Please analyze and fix the GitHub issue: $ARGUMENTS.

      Follow these steps:

      1. Use `gh issue view` to get the issue details
      2. Understand the problem described in the issue
      3. Search the codebase for relevant files
      4. Implement the necessary changes to fix the issue
      5. Write and run tests to verify the fix
      6. Ensure code passes linting and type checking
      7. Create a descriptive commit message
      8. Push and create a PR

      Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.
    '';

    # tmp workaround, previous method of running a cat over config.sops.secrets.gpt-api-key.path stopped working
    programs.zsh.initContent = ''
      export OPENAI_API_KEY="$(cat ~/.config/sops-nix/secrets/gpt-api-key)"
      export ANTHROPIC_API_KEY="$(cat ~/.config/sops-nix/secrets/claude_key)"
      export SOPS_AGE_KEY_FILE="$(cat ~/.config/sops-nix/secrets/sops-age-path)"
      export STARSHIP_CONFIG="${settings.configDir}/starship/starship.toml"
    '';

    home.sessionVariables = {
      DEFAULT_BROWSER =
        if isLinux
        then "${pkgs.firefox}/bin/firefox"
        else "default";

      AICHAT_CONFIG_DIR = "${settings.configDir}/aichat";
      EDITOR = "nvim";
      PAGER = "bat --paging always";
    };

    services.dropbox = {
      path = lib.mkIf isLinux /home/harryp/Dropbox;
      enable = isLinux;
    };
  };
}
