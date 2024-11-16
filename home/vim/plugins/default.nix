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
      # todo enable these when available in systems pkgs
      # avante = {
      #   enable = true;
      # };
      # render-markdown = {
      #   enable = true;
      #   settings.overrides.filetype = ["markdown" "Avante"];
      # };
      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<c-/>]]";
        };
      };
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

      leap.enable = true;
      illuminate.enable = true;
      surround.enable = true;
      comment.enable = true;
      rust-tools.enable = true;
      neo-tree.enable = true;
      dap.enable = true;
    }
    // lsp
    // autocomplete
    // lualine
    // splash-screen;

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
