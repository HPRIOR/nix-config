pkgs: {
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
        {
          name = "nvim_lsp";
          priority = 1000;
        }
        {
          name = "luasnip"; # snippets
          keywordLength = 3;
          priority = 900;
        }
        {
          name = "path"; # file system paths
          keywordLength = 3;
          priority = 400;
        }
      ];
      sorting.comparators = [
        "require('cmp.config.compare').offset"
        "require('cmp.config.compare').exact"
        "require('cmp.config.compare').score"
        ''
          function(entry1, entry2)
            local types = require('cmp.types')
            local kind1 = entry1:get_kind()
            local kind2 = entry2:get_kind()
            kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
            kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
            if kind1 ~= kind2 then
              local diff = kind1 - kind2
              if diff < 0 then
                return true
              elseif diff > 0 then
                return false
              end
            end
            return nil
          end
        ''
        "require('cmp.config.compare').recently_used"
        "require('cmp.config.compare').locality"
        "require('cmp.config.compare').length"
        "require('cmp.config.compare').order"
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
        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
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

  luasnip = {
    enable = true;
    settings = {
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
}
