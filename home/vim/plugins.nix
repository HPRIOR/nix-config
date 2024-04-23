pkgs: {
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
}
