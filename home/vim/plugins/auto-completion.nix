pkgs: {
  blink-cmp-spell.enable = true;
  blink-ripgrep.enable = true;
  colorful-menu.enable = true;
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
        menu.draw = {
          columns = [
            [ "kind_icon" ]
            {
              __unkeyed-1 = "label";
              gap = 1;
            }
          ];
          components.label = {
            text.__raw = ''
              function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end
            '';
            highlight.__raw = ''
              function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end
            '';
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
            "spell"
            "ripgrep"
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
          spell = {
            module = "blink-cmp-spell";
            name = "Spell";
            score_offset = 100;
            opts = {
            };
          };
          ripgrep = {
            async = true;
            module = "blink-ripgrep";
            name = "Ripgrep";
            score_offset = 100;
            opts = {
              prefix_min_len = 3;
              context_size = 5;
              max_filesize = "1M";
              project_root_marker = ".git";
              project_root_fallback = true;
              search_casing = "--ignore-case";
              additional_rg_options = {};
              fallback_to_regex_highlighting = true;
              ignore_paths = {};
              additional_paths = {};
              debug = false;
            };
          };
        };
      };
    };
  };
}
