{
  inputs,
  pkgs,
  rust-packages,
  ...
}: let
  keymaps = import ./keymap.nix;
  plugins = import ./plugins {inherit pkgs rust-packages;};
  options = import ./options.nix;
in {
  imports = [inputs.nixvim.homeManagerModules.nixvim ./ideavim.nix];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  programs.nixvim =
    {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      colorschemes.kanagawa.enable = true;
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

        require("telescope").setup({
            defaults = {
                mappings = {
                i = {
                    ["<S-Tab>"] = "move_selection_next",      -- Move down
                    ["<Tab>"] = "move_selection_previous", -- Move up
                },
                },
            },
          })
        require('telescope').load_extension('notify')

        function create_winbar()
              local navic = "%{%v:lua.require'nvim-navic'.get_location()%}"
              return "%{v:lua.string.gsub(expand('%'), '/', ' > ')} " .. navic
        end

        vim.opt.winbar = create_winbar()

        require'window-picker'.setup()
      '';
      keymaps = keymaps;
      extraPackages = [
        rust-packages.toolchain
        # telescope deps
        pkgs.ripgrep
        pkgs.fzf
        # formatters requred by conform
        pkgs.alejandra
        pkgs.prettierd
        pkgs.nodePackages.prettier
        pkgs.black
        pkgs.stylua
        pkgs.yamlfmt
        pkgs.rustfmt
        pkgs.shfmt
        pkgs.jq
      ];

      globals.mapleader = " ";
      globals.maplocalleader = " ";
    }
    // plugins
    // options;
}
