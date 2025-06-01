[
  {
    key = "<leader>t";
    action = ":NvimTreeToggle<CR>";
    options = {
      noremap = true;
      unique = true;
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
  {
    mode = ["n"];
    key = "<leader>:";
    action = "<cmd>lua Snacks.picker.command_history()<cr>";
    options = {
      silent = true;
      desc = "Search command history";
    };
  }
  {
    mode = ["n"];
    key = "<leader>;";
    action = "<cmd>lua Snacks.picker.buffers() <cr>";
    options = {
      silent = true;
      desc = "Telescope show all buffers";
    };
  }
  {
    mode = ["n"];
    key = "<leader>/";
    action = "<cmd>lua Snacks.picker.lines()<cr>";
    options = {
      silent = true;
      desc = "Search lines in the current buffer";
    };
  }
  {
    mode = ["n"];
    key = "<leader>'";
    action = "<cmd>lua Snacks.picker.marks()<cr>";
    options = {
      silent = true;
      desc = "Telescope marks";
    };
  }
  {
    mode = ["n"];
    key = "<leader>f";
    action = "<cmd>lua Snacks.picker.files()<cr>";
    options = {
      silent = true;
      desc = "Telescope find files";
    };
  }
  {
    mode = ["n"];
    key = "<leader>g";
    action = "<cmd>lua Snacks.picker.grep()<cr>";
    options = {
      silent = true;
      desc = "Telescope live  grep";
    };
  }
  {
    mode = ["n"];
    key = "<leader>G";
    action = "<cmd>lua Snacks.picker.grep_word()<cr>";
    options = {
      silent = true;
      desc = "Telescope live  grep";
    };
  }
  {
    mode = ["n"];
    key = "gd";
    action = "<cmd>lua Snacks.picker.lsp_definitions()<cr>";
    options = {
      silent = true;
      desc = "Telescope go to definition";
    };
  }
  {
    mode = ["n"];
    key = "gD";
    action = "<cmd>lua Snacks.picker.lsp_declarations()<cr>";
    options = {
      silent = true;
      desc = "Telescope go to declaration";
    };
  }
  {
    mode = ["n"];
    key = "gi";
    action = "<cmd>lua Snacks.picker.lsp_implementations()<cr>";
    options = {
      silent = true;
      desc = "Telescope go to implementation";
    };
  }
  {
    mode = ["n"];
    key = "gu";
    action = "<cmd>lua Snacks.picker.lsp_references()<cr>";
    options = {
      silent = true;
      desc = "Telescope find references";
    };
  }
  {
    mode = ["n"];
    key = "gt";
    action = "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>";
    options = {
      silent = true;
      desc = "Telescope find type definitions";
    };
  }
  {
    mode = ["n"];
    key = "<leader>xx";
    action = "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>";
    options = {
      silent = true;
      desc = "Search diagnostics in current buffer";
    };
  }
  {
    mode = ["n"];
    key = "<leader>xa";
    action = "<cmd>lua Snacks.picker.diagnostics()<cr>";
    options = {
      silent = true;
      desc = "Search diagnostics in all buffers";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vl";
    action = "<cmd>lua Snacks.picker.lsp_symbols()<cr>";
    options = {
      silent = true;
      desc = "Search lsp symbols in buffer";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vk";
    action = "<cmd>lua Snacks.picker.keymaps()<cr>";
    options = {
      silent = true;
      desc = "Search lsp symbols in buffer";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vL";
    action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>";
    options = {
      silent = true;
      desc = "Search lsp symbols in workspace";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vn";
    action = "<cmd>lua Snacks.picker.notifications()<cr>";
    options = {
      silent = true;
      desc = "Search through notifications messages extension";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vc";
    action = "<cmd>lua Snacks.picker.commands()<cr>";
    options = {
      silent = true;
      desc = "Search through command history";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vr";
    action = "<cmd>lua Snacks.picker.recent()<cr>";
    options = {
      silent = true;
      desc = "Search through recent files ";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vu";
    action = "<cmd>lua Snacks.picker.undo()<cr>";
    options = {
      silent = true;
      desc = "Search through recent undo";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vd";
    action = "<cmd>lua Snacks.picker.git_diff()<cr>";
    options = {
      silent = true;
      desc = "Search through git diffs";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vj";
    action = "<cmd>lua Snacks.picker.jumps()<cr>";
    options = {
      silent = true;
      desc = "Search through git diffs";
    };
  }
  {
    mode = ["n" "v"];
    key = "<leader>ad";
    action = "<cmd>lua avante_ask_diag()<CR>";
    options = {
      silent = true;
      desc = "Ask Avante to fix errors only if diagnostics exist";
    };
  }
  {
    mode = ["n"];
    key = "<leader>lg";
    action = "<cmd>lua Snacks.lazygit()<cr>";
    options = {
      silent = true;
      desc = "Telescope show all buffers";
    };
  }
  {
    mode = ["n"];
    key = "<leader>A";
    action = "<cmd>AerialNavToggle<cr>";
    options = {
      silent = true;
      desc = "Aerial Nav";
    };
  }
  {
    mode = ["n"];
    key = "<leader>z";
    action = "<cmd>lua Snacks.zen()<cr>";
    options = {
      silent = true;
      desc = "Aerial Nav";
    };
  }
]
