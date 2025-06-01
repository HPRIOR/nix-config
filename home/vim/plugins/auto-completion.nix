pkgs: {
  blink-cmp = let
    border_type = "rounded";
  in {
    enable = true;
    settings = {
      appearance = {
        nerd_font_variant = "normal";
        use_nvim_cmp_as_default = true;
      };
      completion = {
        accept = {
          auto_brackets = {
            enabled = true;
            kind_resolution.enabled = true;
            semantic_token_resolution.enabled = true;
          };
        };
        documentation = {
          auto_show = true;
          window = {
            border = border_type;
          };
        };
      };
      keymap = {
        preset = "enter";
        "<Tab>" = [
          "select_next"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "fallback"
        ];
        "<C-j>" = [
          "scroll_documentation_down"
          "fallback"
        ];
        "<C-k>" = [
          "scroll_documentation_up"
          "fallback"
        ];
      };
      signature = {
        enabled = true;
        window = {
          border = border_type;
        };
      };
      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        cmdline = [];
        providers = {
          buffer = {
            enabled = true;
            score_offset = -7;
          };
          lsp = {
            enabled = true;
            fallbacks = [];
          };
          path = {
            enabled = true;
          };
        };
      };
    };
  };
}
