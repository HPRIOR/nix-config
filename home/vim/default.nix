{
  inputs,
  pkgs,
  settings,
  rust-packages,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  gpt_telescope_cmd_file = "${settings.configDir}/telescope_gpt/cmds.json";
  gpt_config = import ./gpt-plugin.nix;
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

                require("chatgpt").setup({
                  chat = {
                    welcome_message = ""
                  },
                  openai_params = {
                    model = "gpt-4-turbo",
                    max_tokens = 4096,
                  },
                  openai_edit_params = {
                    model = "gpt-4-turbo"
                  },
                  actions_paths = {
                      "${gpt_telescope_cmd_file}"
                  }
                })
                require("telescope").setup({
                    defaults = {
                        mappings = {
                        i = {
                            ["<S-Tab>"] = "move_selection_next",      -- Move down
                            ["<Tab>"] = "move_selection_previous", -- Move up
                        },
                        },
                    },
                      extensions = {
                          ${gpt_config.telescope_ext_config}
                      }
                  })
                require('telescope').load_extension('gpt')
                require('telescope').load_extension('notify')

                function create_winbar()
                      local navic = "%{%v:lua.require'nvim-navic'.get_location()%}"
                      return "%{v:lua.string.gsub(expand('%'), '/', ' > ')} " .. navic
                end

                vim.opt.winbar = create_winbar()

                require'window-picker'.setup()

        -- todo add to nixvim
        --         require("aerial").setup({
        --             -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        --             on_attach = function(bufnr)
        --                 -- Jump forwards/backwards with '{' and '}'
        --                 vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        --                 vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        --             end,
        --             default_direction = "prefer_left",
        --         })
        --         -- You probably also want to set a keymap to toggle aerial
        --         vim.keymap.set("n", "<leader>T", "<cmd>AerialToggle!<CR>")
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

  home.file.${gpt_telescope_cmd_file}.text = gpt_config.telescope_gpt_cmds;
}
