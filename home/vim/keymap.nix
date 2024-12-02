[
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
    action = "<cmd>lua require('conform').format({ lsp_fallback = true })<cr>";
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
    #  todo change severity, currently showing warnings too
    mode = ["n"];
    key = "<leader>vl";
    action = "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>";
    options = {
      silent = true;
      desc = "Telescope lsp workspace symbols";
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
  {
    mode = ["n"];
    key = "<leader>vn";
    action = "<cmd>Telescope notify<cr>";
    options = {
      silent = true;
      desc = "Search through notify messages extension";
    };
  }
]
