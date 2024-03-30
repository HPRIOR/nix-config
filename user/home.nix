{
  config,
  pkgs,
  nixvim,
  ...
}: let
  userName = "harryp";
  homeDir = "/home/harryp";
  dotFiles = "${homeDir}/.dotfiles";
  aliases = {
    # nix editing
    editconfig = "nvim ${dotFiles}/system/configuration.nix";
    buildconfig = "sudo nixos-rebuild switch --flake ${dotFiles}";
    edithome = "nvim ${dotFiles}/user/home.nix";
    buildhome = "home-manager switch --flake ${dotFiles}";
    editnix = "nvim ${dotFiles}";

    # lazy
    lzg = "lazygit";
    lzd = "lazydocker";

    # zsh
    sourcezsh = "source ${homeDir}/.zshrc";

    # modern replacements
    diff = "difft";
    cat = "bat";
    ls = "exa";
    ll = "exa -l";
    lla = "exa -la";
    la = "exa -a";
    changes = "git diff */**";

    copy = "wl-copy";
    paste = "wl-paste";
  };

  # scripts
  nix-build = import ./scripts/nix-build.nix {inherit pkgs;};
in {
  imports = [
    nixvim.homeManagerModules.nixvim
  ];

  home.username = userName;
  home.homeDirectory = homeDir;
  home.stateVersion = "23.05";
  home.packages = [
    nix-build
  ];
  home.file = {};
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMCMD = "${pkgs.kitty}/bin/kitty";
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = false;
    shellAliases = aliases;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo" "copypath" "copyfile" "history"];
      theme = "robbyrussell";
    };
    shellAliases = aliases;
    initExtra = ''
      eval "$(zoxide init zsh)"
    '';
  };

  programs.zoxide = {
    enable = true;
    options = [];
  };
  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   vimdiffAlias = true;
  #   extraLuaConfig = ''
  #   	${builtins.readFile ./neovim/options.lua}
  #   '';
  #   plugins = with pkgs.vimPlugins; [
  #       nvim-lspconfig
  #       nvim-treesitter.withAllGrammars
  #       plenary-nvim
  #       gruvbox-material
  #   ];
  # };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Harry Joseph Prior";
    userEmail = "harryjosephprior@protonmail.com";
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

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    type = "lua";
    colorschemes.kanagawa.enable = true;
    opts = {
      autowrite = true; # Enable auto write
      background = "dark";
      clipboard = "unnamedplus";
      completeopt = "menu,menuone,noselect";
      conceallevel = 3; # Hide * markup for bold and italic
      confirm = true; # Confirm to save changes before exiting modified buffer
      cursorline = true; # Enable highlighting of the current line
      encoding = "UTF-8";
      expandtab = true; # Use spaces instead of tabs
      grepformat = "%f:%l:%c:%m";
      grepprg = "rg #vimgrep";
      ignorecase = true; # Ignore case
      inccommand = "nosplit"; # preview incremental substitute
      laststatus = 3; # global status line
      list = false; # Show some invisible characters (tabs...
      mouse = "a"; # Enable mouse mode
      number = true; # Print line number
      pumblend = 10; # Popup blend
      pumheight = 10; # Maximum number of entries in a popup
      relativenumber = false; # Relative line numbers
      scrolloff = 4; # Lines of context
      sessionoptions = ["buffers" "curdir" "tabpages" "winsize"];
      shiftround = true; # Round indent
      shiftwidth = 4; # Size of an indent
      showmode = false; # Dont show mode since we have a statusline
      sidescrolloff = 8; # Columns of context
      signcolumn = "yes"; # Always show the signcolumn, otherwise it would shift the text each time
      smartcase = true; # Don't ignore case with capitals
      smartindent = true; # Insert indents automatically
      spelllang = "en";
      splitbelow = true; # Put new windows below current
      splitright = true; # Put new windows right of current
      tabstop = 4; # Number of spaces tabs count for
      termguicolors = true; # True color support
      timeoutlen = 300;
      undofile = true;
      undolevels = 10000;
      updatetime = 200; # Save swap file and trigger CursorHold
      wildmode = "longest:full,full"; # Command-line completion mode
      winminwidth = 5; # Minimum window width
      wrap = false; # Disable line wrap
    };
    plugins = {
      notify = {
        enable = true;
        backgroundColour = "#000000";
        fps = 60;
        render = "default";
        timeout = 1000;
        topDown = true;
      };
      telescope = {
        enable = true;
        keymaps = {
          "<leader>g" = "live_grep";
        };
        extensions.fzf-native = {enable = true;};
      };
      nvim-autopairs.enable = true;
      treesitter = {
        enable = true;
        indent = true;
      };
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          jsonls.enable = true;
          nixd.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
        };
      };
      # Code formatting
      conform-nvim = {
        enable = true;
        formatOnSave = {
          lspFallback = true;
          timeoutMs = 500;
        };
        notifyOnError = true;
        formattersByFt = {
          html = [["prettierd" "prettier"]];
          css = [["prettierd" "prettier"]];
          javascript = [["prettierd" "prettier"]];
          javascriptreact = [["prettierd" "prettier"]];
          typescript = [["prettierd" "prettier"]];
          typescriptreact = [["prettierd" "prettier"]];
          python = ["black"];
          lua = ["stylua"];
          nix = ["alejandra"];
          markdown = [["prettierd" "prettier"]];
          yaml = ["yamlfmt"];
          rust = ["rustfmt"];
          sh = ["shfmt"];
        };
      };

      rust-tools.enable = true;
    };
    keymaps = [
      {
        mode = ["n" "v"];
        key = "gf";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format";
        };
      }
    ];
    extraPackages = with pkgs; [
      # telescope deps
      ripgrep
      fzf

      # formatters requred by conform
      alejandra
      prettierd
      nodePackages.prettier
      black
      stylua
      yamlfmt
      rustfmt
      shfmt
    ];

    globals.mapleader = " ";
    globals.maplocalleader = " ";
    extraConfigLua = ''
      local _border = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
          vim.lsp.handlers.hover, {
              border = _border
          }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help, {
              border = _border
          }
      )

      vim.diagnostic.config{
          float={border=_border}
      };

      require('lspconfig.ui.windows').default_options = {
          border = _border
      }
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Required for mouse to render
      env = WLR_NO_HARDWARE_CURSORS,1

      # Startup applications
      exec-once = waybar
      exec-once = blueman-applet

      # Monitor
      monitor=,preferred,auto,1
      monitor=DP-3,3440x1440@74.983002,0x0,1
      monitor=DP-2,2560x2880@29.969999,3440x0,1.5
      monitor=DP-1,3840x2160,-1440x-400,1.5,transform,1
      monitor=HDMI-A-1,disable


      # Key bindings
      $mainMod = SUPER
      $shiftMod = SUPERSHIFT
      bind = $mainMod, Return, exec, kitty
      bind = $shiftMod, Q, killactive

      bind = $mainMod, H, movefocus, l
      bind = $mainMod, J, movefocus, d
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, L, movefocus, r

      bind = $shiftMod, H, movewindow, l
      bind = $shiftMod, J, movewindow, d
      bind = $shiftMod, K, movewindow, u
      bind = $shiftMod, L, movewindow, r

      bind = $mainMod, SPACE, exec, rofi -show drun
      bind = $mainMod, F, fullscreen, 0

      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Switch to submap called resize
      bind=$mainMod,R,submap,resize

      submap=resize
      binde=,L,resizeactive,30 0
      binde=,H,resizeactive,-30 0
      binde=,K,resizeactive,0 -30
      binde=,J,resizeactive,0 30

      # use reset to go back to the global submap
      bind=,escape,submap,reset
      bind=$mainMod,R,submap,reset
      bind=,return,submap,reset

      # Reset submap, normal keybindings resume
      submap=reset


      input {
          kb_layout = gb
          kb_options = caps:swapescape
      }

      misc {
          disable_splash_rendering = true
          disable_hyprland_logo = true
      }

      decoration {
          rounding = 2
          blur {
              enabled = true
              size = 3
              passes = 1
              vibrancy = 0.1696
          }
      }

    '';
  };
}
