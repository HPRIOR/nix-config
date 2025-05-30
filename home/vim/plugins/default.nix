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
      lz-n.enable = true;
      aerial.enable = true;
      dropbar.enable = true;
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
      zen-mode.enable = true;
      neogit.enable = true;
      gitsigns.enable = true;
      diffview.enable = true;
      auto-session.enable = true;
      guess-indent = {
        enable = true;
        settings = {
          filetype_exclude = ["ocaml"];
        };
      };
      colorizer.enable = true;
      web-devicons.enable = true;
      # todo enable these when available in systems pkgs
      avante = {
        enable = true;
        settings = {
          provider = "claude";
          claude = {
            model = "claude-3-5-sonnet-20241022";
          };
        };
      };
      render-markdown = {
        enable = true;

        settings = {
          file_types = ["markdown" "Avante"];
        };
      };
      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<c-/>]]";
        };
      };
      notify = {
        enable = true;
        settings = {
          backgroundColour = "#000000";
          fps = 60;
          render = "default";
          timeout = 1000;
          topDown = true;
        };
      };
      snacks = {
        enable = true;
        settings = {
          animate = {
            enabled = true;
          };
          bigfile = {
            enabled = true;
          };
          lazygit = {
            enabled = true;
          };
          quickfile = {
            enabled = true;
          };
          scroll = {
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
      nvim-tree.enable = true;
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
