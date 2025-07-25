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

        -- avante helpers

        -- Returns a table of diagnostics under cursor, or nil if none found.
        function get_diagnostics_under_cursor_or_selection()
          local bufnr = 0 -- Current buffer
          local mode = vim.fn.mode()

          -- Detect if we are in a visual mode (characterwise "v", linewise "V", or blockwise "").
          if mode == 'v' or mode == 'V' or mode == '\022' then
            -- Get start/end marks for the < and > marks, which store the visual selection boundaries.
            local start_pos = vim.fn.getpos("'<")  -- {bufnum, line, col, off}
            local end_pos   = vim.fn.getpos("'>")  -- same structure

            -- The line numbers from getpos() are 1-based, just like vim.api.nvim_win_get_cursor().
            -- Make sure we identify the smaller and larger line, in case user selects "backwards".
            local start_line = math.min(start_pos[2], end_pos[2])
            local end_line   = math.max(start_pos[2], end_pos[2])

            -- Get all diagnostics, then filter by the selected line range.
            local all_diags = vim.diagnostic.get(bufnr)
            local selection_diags = {}
            for _, diag in ipairs(all_diags) do
              -- diag.lnum is 0-based, so subtract 1 from start/end_line for comparison.
              if diag.lnum >= (start_line - 1) and diag.lnum <= (end_line - 1) then
                table.insert(selection_diags, diag)
              end
            end

            if #selection_diags == 0 then
              return nil
            end
            return selection_diags
          else
            -- No visual selection, just get the diagnostics under the cursor line.
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            local row = cursor_pos[1] -- 1-based line index
            local diags = vim.diagnostic.get(bufnr, { lnum = row - 1 })
            if not diags or #diags == 0 then
              return nil
            end
            return diags
          end
        end

        -- Format a table of diagnostics into a string, or return an empty string if none.
        function format_diagnostics(diagnostics)
          -- If diagnostics is nil or empty, return an empty string (or a message).
          if not diagnostics or #diagnostics == 0 then
            return ""
          end

          local severity_map = {
            [1] = "Error",
            [2] = "Warning",
            [3] = "Info",
            [4] = "Hint"
          }

          local lines = {}
          for _, diag in ipairs(diagnostics) do
            local sev = severity_map[diag.severity] or "Unknown"
            -- Handle nil safely by providing fallbacks (here we do "N/A" if missing).
            local code = diag.code or "N/A"
            local lnum = diag.lnum or 0
            local col = diag.col or 0
            local msg = diag.message or ""

            local formatted = string.format(
              "%s [%s] at line %d, col %d: %s",
              sev, code, lnum, col, msg
            )
            table.insert(lines, formatted)
          end

          return table.concat(lines, "\n")
        end

        function avante_ask_diag()
          local diags = get_diagnostics_under_cursor_or_selection()
          if not diags then
            print("No diagnostics under cursor")
            return
          end
          local formatted = format_diagnostics(diags)
          require("avante.api").ask {
            question = "Explain these diagnostics and offer a solution:\n" .. formatted
          }
        end

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
