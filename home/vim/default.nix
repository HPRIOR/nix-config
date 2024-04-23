{
  inputs,
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  gpt_telescope_cmd_file = "${settings.configDir}/telescope_gpt/cmds.json";
  gpt_config = import ./gpt-plugin.nix;
in {
  imports = [inputs.nixvim.homeManagerModules.nixvim ./ideavim.nix];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
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
    plugins = import ./plugins.nix pkgs;
    extraPlugins = with pkgs.vimPlugins; [
      dressing-nvim
      ChatGPT-nvim
      nvim-window-picker
      (pkgs.vimUtils.buildVimPlugin {
        name = "telescope-gpt";
        src = pkgs.fetchFromGitHub {
          owner = "HPRIOR";
          repo = "telescope-gpt";
          rev = "main";
          hash = "sha256-fGCgayTQKdyx6UElUx4+2jQr3HPUfmaaONjcuW2PDDU=";
        };
      })
    ];
    extraConfigLua = ''
      -- configure dressing-nvim
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
          require("lazy").load({ plugins = { "dressing.nvim" } })
          return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
          require("lazy").load({ plugins = { "dressing.nvim" } })
          return vim.ui.input(...)
      end

      -- configure lsp
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

      vim.diagnostic.config = {
          float={border=_border}
      }

      require('lspconfig.ui.windows').default_options = {
          border = _border
      }

      require("chatgpt").setup({
        actions_paths = {
            "${gpt_telescope_cmd_file}"
        }
      })
      require("telescope").setup({
            extensions = {
                ${gpt_config.telescope_ext_config}
            }
        })
      require('telescope').load_extension('gpt')

      function create_winbar()
            local navic = "%{%v:lua.require'nvim-navic'.get_location()%}"
            return "%{v:lua.string.gsub(expand('%'), '/', ' > ')} " .. navic
      end

      vim.opt.winbar = create_winbar()

      require'window-picker'.setup()
    '';
    keymaps = import ./keymap.nix;
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
      jq
    ];

    globals.mapleader = " ";
    globals.maplocalleader = " ";
  };

  home.file.${gpt_telescope_cmd_file}.text = gpt_config.telescope_gpt_cmds;
}
