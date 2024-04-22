{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
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
    plugins = {
      navic = {
        enable = true;
        lsp.autoAttach = true;
      };
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
        settings = {
          pickers = {
            command_history = {
              theme = "dropdown";
            };
            builtin = {
              theme = "dropdown";
            };
            lsp_definitions = {
              theme = "ivy";
            };
            lsp_references = {
              theme = "ivy";
            };
            diagnostics = {
              theme = "ivy";
            };
          };
        };
        extensions = {
          fzf-native.enable = true;
          # ui-select.enable = true;
        };
      };
      nvim-autopairs.enable = true;
      treesitter = {
        enable = true;
        indent = true;
      };
      lsp = {
        enable = true;
        onAttach = ''
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
        '';
        servers = {
          bashls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          dockerls.enable = true;
          elmls.enable = true;
          fsautocomplete.enable = true;
          html.enable = true;
          jsonls.enable = true;
          lua-ls.enable = true;
          marksman.enable = true;
          nixd.enable = true;
          ocamllsp.enable = true;
          omnisharp.enable = true;
          pyright.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          yamlls.enable = true;
        };
        keymaps.lspBuf = {
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
          "<leader>a" = "code_action";
          "<leader>r" = "rename";
        };
        keymaps.diagnostic = {
          "ge" = "goto_next";
          "gE" = "goto_prev";
          "<leader>d" = "open_float";
        };
      };
      # Code formatting
      conform-nvim = {
        enable = true;
        # formatOnSave = {
        #   lspFallback = true;
        #   timeoutMs = 500;
        # };
        notifyOnError = true;
        formattersByFt = {
          html = [["prettierd" "prettier"]];
          css = [["prettierd" "prettier"]];
          json = [["jq"]];
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

      lspkind = {
        enable = true;
        extraOptions = {
          maxwidth = 50;
          ellipsis_char = "...";
        };
      };
      luasnip = {
        enable = true;
        extraConfig = {
          enable_autosnippets = true;
          store_selection_keys = "<Tab>";
        };
        fromVscode = [
          {
            lazyLoad = true;
            paths = "${pkgs.vimPlugins.friendly-snippets}";
          }
        ];
      };

      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          experimental = {ghost_text = false;};
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 30;
          };
          snippet = {expand = "function(args) require('luasnip').lsp_expand(args.body) end";};
          formatting = {fields = ["kind" "abbr" "menu"];};
          sources = [
            {name = "nvim_lsp";}
            {
              name = "path"; # file system paths
              keywordLength = 3;
            }
            {
              name = "luasnip"; # snippets
              keywordLength = 3;
            }
          ];

          window = {
            completion = {
              border = "rounded";
              winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
            };
            documentation = {border = "rounded";};
          };

          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-e>" = "cmp.mapping.abort()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          };
        };
      };
      lualine = {
        enable = true;
        globalstatus = true;
        disabledFiletypes = {
          statusline = ["dashboard" "alpha"];
        };
        theme = {
          normal = {
            a = {
              bg = "#b4befe";
              fg = "#1c1d21";
            };
            b = {
              bg = "nil";
            };
            c = {
              bg = "nil";
            };
            z = {
              bg = "nil";
            };
            y = {
              bg = "nil";
            };
            x = {
              bg = "nil";
            };
          };
        };
        componentSeparators = {
          left = "";
          right = " ";
        };
        sectionSeparators = {
          left = "";
          right = "";
        };
        sections = {
          lualine_a = [
            {
              name = "mode";
              icon = "";
              separator = {
                left = "";
                right = "";
              };
            }
          ];
          lualine_b = [
            {
              name = "branch";
              icon = "";
              separator = {
                left = "";
                right = "";
              };
              color = {
                fg = "#1c1d21";
                bg = "#7d83ac";
              };
            }
          ];
          lualine_c = [
            {
              name = "diagnostic";
              extraConfig = {
                symbols = {
                  error = " ";
                  warn = " ";
                  info = " ";
                  hint = "󰝶 ";
                };
              };
            }
            {
              name = "filetype";
              separator = {
                left = "";
                right = "";
              };
              extraConfig = {
                icon_only = true;
                padding = {
                  left = 1;
                  right = 0;
                };
              };
            }
            {
              name = "filename";
              extraConfig = {
                symbols = {
                  modified = "  ";
                  readonly = "";
                  unnamed = "";
                };
              };
            }
          ];
          lualine_x = [
            "diff"
          ];
          lualine_y = [
            {
              name = "progress";
              icon = "";
              color = {
                fg = "#1c1d21";
                bg = "#f2cdcd";
              };
            }
          ];
          lualine_z = [
            {
              name = "location";
              color = {
                fg = "#1c1d21";
                bg = "#f2cdcd";
              };
            }
          ];
        };
      };
      alpha = let
        nixFlake = ''
                     III      ~+===~     =+=
                    IIIII      +====:   =====
                     IIIII      =====  ======
                     +IIII7      ====+:====~
                      7IIII       =========
                =IIIIIIIIIIIIIIIII,=======      =
               ~IIIIIIIIIIIIIIIIIII =====      +7:
               IIIIIIIIIIIIIIIIIIIII =====     III:
                      =====           =====   IIII7
                     =====~            ===== IIIII
                    :====~             ~=== IIIII
           ::::::::~====+               ~= IIIII??????
          =============+                 ,7IIIIIIIIIIII
          +============?                 IIIIIIIIIIIIII
                 ====+,II               7IIII
                =====,IIII             IIIII~
               ===== ~IIIII           ?IIII~
              =====   ?IIII~         ~IIII7
               ===     7IIII:=====================
                +       IIIII ===================
                       IIIIIII =================,
                      7IIIIIII7       =====
                     7IIII~7IIII       =====
                    IIIII~  IIIII      :====+
                    7IIII    IIIII      :===+
        '';
      in {
        enable = true;
        layout = [
          {
            type = "padding";
            val = 4;
          }
          {
            opts = {
              hl = "AlphaHeader";
              position = "center";
            };
            type = "text";
            val = nixFlake;
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "group";
            val = let
              mkButton = shortcut: cmd: val: hl: {
                type = "button";
                inherit val;
                opts = {
                  inherit hl shortcut;
                  keymap = [
                    "n"
                    shortcut
                    cmd
                    {}
                  ];
                  position = "center";
                  cursor = 0;
                  width = 40;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              };
            in [
              (
                mkButton
                "f"
                "<CMD>lua require('telescope.builtin').find_files()<CR>"
                "🔍 Find File"
                "Operator"
              )
              (
                mkButton
                "t"
                "<cmd>lua require('neo-tree.command').execute({ toggle = true })<cr>"
                "  Open tree"
                "Operator"
              )
              (
                mkButton
                "q"
                "<CMD>qa<CR>"
                "💣 Quit Neovim"
                "String"
              )
            ];
          }
          {
            type = "padding";
            val = 2;
          }
        ];
      };
      leap.enable = true;
      illuminate.enable = true;
      surround.enable = true;
      comment.enable = true;
      rust-tools.enable = true;
      neo-tree.enable = true;
    };
    extraPlugins = with pkgs.vimPlugins; [
      dressing-nvim
      ChatGPT-nvim
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
            extensions = {
                gpt = {
                    title = "Gpt Actions",
                    commands = {
                        "add_tests",
                        "chat",
                        "docstring",
                        "explain_code",
                        "fix_bugs",
                        "grammar_correction",
                        "interactive",
                        "optimize_code",
                        "summarize",
                        "translate"
                    },
                    theme = require("telescope.themes").get_dropdown{}
                }
            }
        })
        require('telescope').load_extension('gpt')

        function create_winbar() 
            local navic = "%{%v:lua.require'nvim-navic'.get_location()%}"
            return "%{v:lua.string.gsub(expand('%'), '/', ' > ')} " .. navic
        end

        vim.opt.winbar = create_winbar()
    '';
    keymaps = [
      {
        key = "<leader>t";
        action = "<cmd>lua require('neo-tree.command').execute({ toggle = true })<cr>";
        options = {
          silent = true;
          desc = "Toggle neotree";
        };
      }
      {
        mode = ["n" "v"];
        key = "gf";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format buffer or selection";
        };
      }
      {
        mode = ["v"];
        key = "<C-p>";
        action = "y'>p";
        options = {
          silent = true;
          desc = "Copy visual selection below";
        };
      }
      {
        mode = ["n"];
        key = "<C-s>";
        action = ":setlocal spell! spelllang=en_gb<CR>";
        options = {
          silent = true;
          desc = "Toggle spell checker";
        };
      }
      {
        mode = ["n"];
        key = "<leader>s";
        action = "<cmd>lua require'telescope.builtin'.spell_suggest(require('telescope.themes').get_dropdown({ width = 0.8, previewer = false, prompt_title = false }))<cr>";
        options = {
          silent = true;
          desc = "Toggle spell checker";
        };
      }
      {
        mode = ["n"];
        key = "<leader>vr";
        action = "<cmd>lua require('rust-tools.runnables').runnables()<CR>";
        options = {
          silent = true;
          desc = "Open rust runnables";
        };
      }
      {
        mode = ["n"];
        key = "<leader>h";
        action = "<c-w>h";
        options = {
          silent = true;
          desc = "Move to left window";
        };
      }
      {
        mode = ["n"];
        key = "<leader>j";
        action = "<c-w>j";
        options = {
          silent = true;
          desc = "Move to lower window";
        };
      }
      {
        mode = ["n"];
        key = "<leader>k";
        action = "<c-w>k";
        options = {
          silent = true;
          desc = "Move to upper window";
        };
      }
      {
        mode = ["n"];
        key = "<leader>l";
        action = "<c-w>l";
        options = {
          silent = true;
          desc = "Move to right window";
        };
      }
      {
        mode = ["n"];
        key = "=";
        action = ":vertical resize +5<CR>";
        options = {
          silent = true;
          desc = "Expand vertical window size";
        };
      }
      {
        mode = ["n"];
        key = "-";
        action = ":vertical resize -5<CR>";
        options = {
          silent = true;
          desc = "Reduce vertical window size";
        };
      }
      {
        mode = ["n"];
        key = "+";
        action = ":resize +5<CR>";
        options = {
          silent = true;
          desc = "Resize right";
        };
      }
      {
        mode = ["n"];
        key = "_";
        action = ":resize -5<CR>";
        options = {
          silent = true;
          desc = "Resize left";
        };
      }
      {
        mode = ["n"];
        key = "<leader>=";
        action = "<c-w>=";
        options = {
          silent = true;
          desc = "Make all splits equal size";
        };
      }
      {
        mode = ["n"];
        key = "<leader>w";
        action = ":close <cr>";
        options = {
          silent = true;
          desc = "Close buffer";
        };
      }
      # Telescope  bindings
      {
        mode = ["n"];
        key = "<leader>:";
        action = "<cmd>Telescope command_history<cr>";
        options = {
          silent = true;
          desc = "Telescope command history";
        };
      }
      {
        mode = ["n"];
        key = "<leader>;";
        action = "<cmd>Telescope buffers show_all_buffers=true<cr>";
        options = {
          silent = true;
          desc = "Telescope show all buffers";
        };
      }
      {
        mode = ["n"];
        key = "<leader>/";
        action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
        options = {
          silent = true;
          desc = "Telescope fuzzy find through current buffer";
        };
      }
      {
        mode = ["n"];
        key = "<leader>'";
        action = "<cmd>Telescope marks<cr>";
        options = {
          silent = true;
          desc = "Telescope marks";
        };
      }
      {
        mode = ["n"];
        key = "<leader>f";
        action = "<cmd>Telescope find_files<cr>";
        options = {
          silent = true;
          desc = "Telescope find files";
        };
      }
      {
        mode = ["n"];
        key = "<leader>g";
        action = "<cmd>Telescope live_grep<cr>";
        options = {
          silent = true;
          desc = "Telescope live  grep";
        };
      }
      {
        mode = ["n"];
        key = "gd";
        action = "<cmd>lua require'telescope.builtin'.lsp_definitions()<cr>";
        options = {
          silent = true;
          desc = "Telescope go to definition";
        };
      }
      {
        mode = ["n"];
        key = "gu";
        action = "<cmd>lua require'telescope.builtin'.lsp_references()<cr>";
        options = {
          silent = true;
          desc = "Telescope find references";
        };
      }
      {
        #  todo change severity, currently showing warnings too
        mode = ["n"];
        key = "<leader>xx";
        action = "<cmd>lua require'telescope.builtin'.diagnostics({ bufnr = 0 })<cr>";
        options = {
          silent = true;
          desc = "Telescope diagnostics in current buffer";
        };
      }
      {
        #  todo change severity, currently showing warnings too
        mode = ["n"];
        key = "<leader>xa";
        action = "<cmd>lua require'telescope.builtin'.diagnostics()<cr>";
        options = {
          silent = true;
          desc = "Telescope diagnostics in all buffers";
        };
      }
      {
        mode = ["n" "v"];
        key = "<C-c>";
        action = ":ChatGPT<CR>";
        options = {
          silent = true;
          desc = "Open chat gpt plugin";
        };
      }
      {
        mode = ["n" "v"];
        key = "<C-a>";
        action = "<cmd>Telescope gpt<cr>";
        options = {
          silent = true;
          desc = "Open chat gpt telescope extension";
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
      jq
    ];

    globals.mapleader = " ";
    globals.maplocalleader = " ";
  };
}
