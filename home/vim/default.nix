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
  keymaps = import ./keymap.nix;
  plugins = import ./plugins pkgs;
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
      type = "lua";
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
      keymaps = keymaps;
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
    }
    // plugins
    // options;

  home.file.${gpt_telescope_cmd_file}.text = gpt_config.telescope_gpt_cmds;
}
