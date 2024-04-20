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
    ./mac
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

    #  https://github.com/nix-community/home-manager/issues/1341 is closed.
    # creates aliases to nix store so that spotlight can search for nix installed packages
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

    sops = let
      # This is a bit hacky, but works - %r replacement for runtime tmp path doesn't work according to sops-nix docs
      runtimePath =
        if isLinux
        then "$XDG_RUNTIME_DIR/secrets" # must include leading slash because of command below
        else "$(getconf DARWIN_USER_TEMP_DIR)secrets.d/1";
    in {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        # Private key generated using ssh and `nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt`
        keyFile = "/etc/sops/age/keys.txt";
      };
      secrets.gpt-api-key = {path = "${runtimePath}/gpt-api-key";};
      secrets.server-ip = {path = "${runtimePath}/server-ip";};
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
    };

    # todo not compat with darwin, 
    # services.dropbox.path = "~/Dropbox";
    # services.dropbox.enable = true;
  };
}
