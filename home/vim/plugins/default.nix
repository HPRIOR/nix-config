{
  pkgs,
  config,
  rust-packages,
}: let
  lsp = import ./lsp.nix {inherit pkgs rust-packages;};
  autocomplete = import ./auto-completion.nix pkgs;
  lualine = import ./lualine.nix;
  splash-screen = import ./splash-screen.nix;
in {
  plugins =
    {
      actions-preview = {
        enable = true;
        settings = {
          backend = ["snacks" "telescope" "minipick"];
          snacks = {
            layout = {preset = "dropdown";};
          };
        };
      };
      lz-n.enable = true;
      scrollview.enable = true;
      aerial.enable = true;
      dropbar.enable = true;
      spectre.enable = true;
      smear-cursor = {
        enable = true;
        settings = {
          stiffness = 0.8;
          trailing_stiffness = 0.5;
          distance_stop_animating = 0.5;
        };
      };
      smart-splits.enable = true;
      bullets = {
        enable = true;
        settings = {
          enable_in_empty_buffers = 0;
          enabled_file_types = [
            "markdown"
            "text"
            "gitcommit"
            "scratch"
          ];
          nested_checkboxes = 0;
        };
      };
      gitsigns.enable = true;
      wrapping.enable = true;
      trouble = {enable = true;};
      vim-matchup.enable = true;
      tiny-inline-diagnostic.enable = false;
      auto-session.enable = true;
      guess-indent = {
        enable = true;
        settings = {
          filetype_exclude = ["ocaml"];
        };
      };
      colorizer.enable = true;
      web-devicons.enable = true;
      mini.enable = true;
      # todo enable these when available in systems pkgs
      avante = {
        enable = true;
        settings = {
          provider = "claude";
          claude = {
            max_tokens = 8192;
            model = "claude-3-5-sonnet-20241022";
            disable_tools = ["web_search"];
          };
        };
      };
      render-markdown = {
        enable = true;

        settings = {
          file_types = ["markdown" "Avante"];
        };
      };
      snacks = {
        enable = true;
        settings = {
          animate = {enabled = true;};
          bigfile = {enabled = true;};
          indent = {
            enabled = true;
            animate = {enabled = false;};
          };
          lazygit = {enabled = true;};
          notifier = {
            enabled = true;
            timeout = 3000;
          };
          picker = {enabled = true;};
          quickfile = {enabled = true;};
          scroll = {enabled = true;};
          zen = {
            enabled = true;
            toggles = {
              dim = false;
            };
          };
          terminal = {
            enabled = true;
          };
        };
      };
      telescope = {
        enable = true;
        lazyLoad = {
          enable = true;
          settings = {
            cmd = "Telescope";
          };
        };
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
        };
      };
      nvim-autopairs.enable = true;
      treesitter-context.enable = true;
      treesitter-textobjects.enable = true;
      treesitter = {
        settings = {
          indent = {
            enable = true;
            # disable = ["ocaml"];
          };
          highlight.enable = true;
        };
        enable = true;
      };
      # Code formatting
      conform-nvim = {
        enable = true;
        settings.notifyOnError = true;
        settings.formatters_by_ft = {
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
          ocaml = ["ocamlformat"];
        };
      };

      leap.enable = true;
      illuminate.enable = true;
      vim-surround.enable = true;
      comment.enable = true;
      neo-tree.enable = true;
      dap.enable = true;
    }
    // lsp
    // autocomplete
    // lualine
    // splash-screen;

  extraPlugins = with pkgs.vimPlugins; [
    nvim-window-picker
  ];
}
