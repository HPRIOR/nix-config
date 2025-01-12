{
  pkgs,
  rust-packages,
}: let
  lsp = import ./lsp.nix {inherit pkgs rust-packages;};
  autocomplete = import ./auto-completion.nix pkgs;
  lualine = import ./lualine.nix;
  splash-screen = import ./splash-screen.nix;
in {
  plugins =
    {
      guess-indent.enable = true;
      nvim-colorizer.enable = true;
      neoscroll.enable = true;
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
      navic = {
        enable = true;
        settings.lsp.autoAttach = true;
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
        };
      };
      nvim-autopairs.enable = true;
      treesitter = {
        settings = {
          indent.enable = true;
          highlight.enable = true;
          ensure_installed = "all";
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
    dressing-nvim
    nvim-window-picker
  ];
}
