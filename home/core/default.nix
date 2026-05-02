{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.features;
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  darwinChromePath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
in {
  imports = [
    ../options.nix
    ../packages
    inputs.nix-colours.homeManagerModules.default
  ];

  config = {
    home.username = config.my.identity.userName;
    home.homeDirectory = config.my.identity.homeDir;
    home.stateVersion = "25.11";

    colorScheme = inputs.nix-colours.colorSchemes.${config.my.appearance.theme};

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

    programs.home-manager.enable = cfg.homeManager.enable;

    programs.git = lib.mkIf cfg.git.enable {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user.name = config.my.identity.fullName;
        user.email = config.my.identity.email;
        core.autocrlf = "input";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        alias.lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };

    programs.delta = lib.mkIf cfg.git.enable {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "side-by-side line-numbers decorations";
        whitespace-error-style = "22 reverse";
        navigate = "true";
      };
    };

    programs.yazi = lib.mkIf cfg.yazi.enable {
      enable = true;
      keymap.mgr.prepend_keymap = [
        {
          on = "!";
          "for" = "unix";
          run = ''shell "$SHELL" --block'';
          desc = "Open shell here";
        }
      ];
      settings = lib.optionalAttrs isLinux {
        opener.play = [
          {
            run = "vlc \"$@\"";
            desc = "VLC";
            orphan = true;
            "for" = "linux";
          }
        ];
        open.prepend_rules = [
          {
            mime = "video/*";
            use = "play";
          }
        ];
      };
    };

    services.syncthing.enable = cfg.syncthing.enable;

    programs.atuin = lib.mkIf cfg.atuin.enable {
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
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "/etc/sops/age/keys.txt";
      };
      secrets.gpt-api-key = {};
      secrets.server-ip = {};
      secrets.claude_key = {};
      secrets.sops-age-path = {};
      secrets.atuin-key = {};
    };

    systemd.user.services.mbsync.unitConfig.After = ["sops-nix.service"];

    # tmp workaround: https://github.com/Mic92/sops-nix/issues/890
    launchd.agents.sops-nix = lib.mkIf isDarwin {
      enable = true;
      config.EnvironmentVariables.PATH = lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
    };

    programs.zsh.initContent = lib.mkIf cfg.aiTools.enable ''
      export OPENAI_API_KEY="$(cat ${config.sops.secrets.gpt-api-key.path})"
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.claude_key.path})"
      export SOPS_AGE_KEY_FILE="$(cat ${config.sops.secrets.sops-age-path.path})"
      export STARSHIP_CONFIG="${config.my.paths.configDir}/starship/starship.toml"
    '';

    home.sessionVariables =
      {
        DEFAULT_BROWSER =
          if isLinux
          then "${pkgs.firefox}/bin/firefox"
          else "default";

        AICHAT_CONFIG_DIR = "${config.my.paths.configDir}/aichat";
        EDITOR = "nvim";
        PAGER = "bat --paging always";
      }
      // lib.optionalAttrs isDarwin {
        CHROME_PATH = darwinChromePath;
        PUPPETEER_EXECUTABLE_PATH = darwinChromePath;
      };

    services.dropbox = lib.mkIf isLinux {
      path = "${config.my.identity.homeDir}/Dropbox";
      enable = cfg.dropbox.enable;
    };
  };
}
