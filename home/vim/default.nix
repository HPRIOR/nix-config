{
  inputs,
  pkgs,
  config,
  ...
}: let
  keymaps = import ./keymap.nix;
  plugins = import ./plugins {inherit pkgs config;};
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
      performance = {
        combinePlugins.enable = true;
        combinePlugins.standalonePlugins = ["nvim-treesitter" "blink.cmp" "smart-splits" "leap.nvim" "mini.nvim"];
        byteCompileLua = {
          enable = true;
          configs = true;
          initLua = true;
          nvimRuntime = true;
          plugins = true;
        };
      };
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      colorschemes.kanagawa = {
        enable = true;
        lazyLoad.enable = true;
      };
      extraConfigLua = ''
        vim.g.no_ocaml_maps = 1

        -- configure lsp
        local _border = "rounded"
        local border_colour = "#2D4F67"

        local kanagawa_background = "#1f1f28"
        vim.api.nvim_set_hl(0, "BlinkCmpMenu", {background = "#223249" })



        -- Set up floating window appearance
        -- This messes with snacks slightly. Because the background is dimmed you can see the box outline
        -- Set floating border color and background
        vim.api.nvim_set_hl(0, "FloatBorder", {
            bg = kanagawa_background,
            fg = border_colour
        })

        -- hacky fix to match border with dimmed backdrop
        vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "#16161D", fg = border_colour})


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

        vim.diagnostic.config({
            virtual_text = false,
            float = {
                border = _border,
                style = "minimal",
            },
            signs = {
              text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "󰋼",
                [vim.diagnostic.severity.HINT] = "󰌵",
              },
            },
            underline = true,
            severity_sort = true,
        })

        require('lspconfig.ui.windows').default_options = {
            border = _border,
        }


        -- Set rounded borders for all floating windows
        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or _border
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

        -- Telescope settings
        -- Settings.defaults.mappings seems ot be broken in the nix config
        -- Some extensions aren't provided as well
        require("telescope").setup({
            defaults = {
                mappings = {
                i = {
                    ["<C-j>"] = "move_selection_next",      -- Move down
                    ["<C-k>"] = "move_selection_previous", -- Move up
                },
                },
            },
          })
        require'window-picker'.setup()

      '';
      keymaps = keymaps;
      extraPackages = [
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
        # pkgs.ocamlPackages.ocamlformat
      ];

      globals.mapleader = " ";
      globals.maplocalleader = " ";
    }
    // plugins
    // options;
}
