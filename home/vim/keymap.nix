[
  {
    key = "<leader>t";
    action = ":Neotree toggle<CR>";
    options = {
      noremap = true;
      unique = true;
      silent = true;
      desc = "Toggle file explorer";
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
      desc = "Paste selection below";
    };
  }
  {
    mode = ["n"];
    key = "<C-s>";
    action = ":setlocal spell! spelllang=en_gb<CR>";
    options = {
      silent = true;
      desc = "Toggle spell checking";
    };
  }
  {
    mode = ["n"];
    key = "<leader>s";
    action = "<cmd>lua require'telescope.builtin'.spell_suggest(require('telescope.themes').get_dropdown({ width = 0.8, previewer = false, prompt_title = false }))<cr>";
    options = {
      silent = true;
      desc = "Show spelling suggestions";
    };
  }
  {
    mode = ["n"];
    key = "<leader>h";
    action = "<c-w>h";
    options = {
      silent = true;
      desc = "Focus window left";
    };
  }
  {
    mode = ["n"];
    key = "<leader>j";
    action = "<c-w>j";
    options = {
      silent = true;
      desc = "Focus window below";
    };
  }
  {
    mode = ["n"];
    key = "<leader>k";
    action = "<c-w>k";
    options = {
      silent = true;
      desc = "Focus window above";
    };
  }
  {
    mode = ["n"];
    key = "<leader>l";
    action = "<c-w>l";
    options = {
      silent = true;
      desc = "Focus window right";
    };
  }
  {
    mode = ["n"];
    key = "=";
    action = ":vertical resize +5<CR>";
    options = {
      silent = true;
      desc = "Increase window width";
    };
  }
  {
    mode = ["n"];
    key = "-";
    action = ":vertical resize -5<CR>";
    options = {
      silent = true;
      desc = "Decrease window width";
    };
  }
  {
    mode = ["n"];
    key = "+";
    action = ":resize +5<CR>";
    options = {
      silent = true;
      desc = "Increase window height";
    };
  }
  {
    mode = ["n"];
    key = "_";
    action = ":resize -5<CR>";
    options = {
      silent = true;
      desc = "Decrease window height";
    };
  }
  {
    mode = ["n"];
    key = "<leader>=";
    action = "<c-w>=";
    options = {
      silent = true;
      desc = "Equalize split sizes";
    };
  }
  {
    mode = ["n"];
    key = "<leader>w";
    action = ":close <cr>";
    options = {
      silent = true;
      desc = "Close current window";
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
      desc = "Show open buffers";
    };
  }
  {
    mode = ["n"];
    key = "<leader>/";
    action = "<cmd>lua Snacks.picker.lines()<cr>";
    options = {
      silent = true;
      desc = "Search lines in buffer";
    };
  }
  {
    mode = ["n"];
    key = "<leader>'";
    action = "<cmd>lua Snacks.picker.marks()<cr>";
    options = {
      silent = true;
      desc = "List marks";
    };
  }
  {
    mode = ["n"];
    key = "<leader>f";
    action = "<cmd>lua Snacks.picker.files()<cr>";
    options = {
      silent = true;
      desc = "Find files";
    };
  }
  {
    mode = ["n"];
    key = "<leader>g";
    action = "<cmd>lua Snacks.picker.grep()<cr>";
    options = {
      silent = true;
      desc = "Live grep search";
    };
  }
  {
    mode = ["n"];
    key = "<leader>G";
    action = "<cmd>lua Snacks.picker.grep_word()<cr>";
    options = {
      silent = true;
      desc = "Search word under cursor";
    };
  }
  {
    mode = ["n"];
    key = "gd";
    action = "<cmd>lua Snacks.picker.lsp_definitions()<cr>";
    options = {
      silent = true;
      desc = "Go to definition";
    };
  }
  {
    mode = ["n"];
    key = "gD";
    action = "<cmd>lua Snacks.picker.lsp_declarations()<cr>";
    options = {
      silent = true;
      desc = "Go to declaration";
    };
  }
  {
    mode = ["n"];
    key = "gi";
    action = "<cmd>lua Snacks.picker.lsp_implementations()<cr>";
    options = {
      silent = true;
      desc = "Go to implementation";
    };
  }
  {
    mode = ["n"];
    key = "gu";
    action = "<cmd>lua Snacks.picker.lsp_references()<cr>";
    options = {
      silent = true;
      desc = "Find references";
    };
  }
  {
    mode = ["n"];
    key = "gt";
    action = "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>";
    options = {
      silent = true;
      desc = "Go to type definition";
    };
  }
  {
    mode = ["n"];
    key = "<leader>xx";
    action = "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>";
    options = {
      silent = true;
      desc = "Show buffer diagnostics";
    };
  }
  {
    mode = ["n"];
    key = "<leader>xa";
    action = "<cmd>Trouble diagnostics toggle focus=true<cr>";
    options = {
      silent = true;
      desc = "Show workspace diagnostics";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vl";
    action = "<cmd>lua Snacks.picker.lsp_symbols()<cr>";
    options = {
      silent = true;
      desc = "List symbols in buffer";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vk";
    action = "<cmd>lua Snacks.picker.keymaps()<cr>";
    options = {
      silent = true;
      desc = "Search keymaps";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vL";
    action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>";
    options = {
      silent = true;
      desc = "Search workspace symbols";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vn";
    action = "<cmd>lua Snacks.picker.notifications()<cr>";
    options = {
      silent = true;
      desc = "Search notifications";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vc";
    action = "<cmd>lua Snacks.picker.commands()<cr>";
    options = {
      silent = true;
      desc = "Search commands";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vr";
    action = "<cmd>lua Snacks.picker.recent()<cr>";
    options = {
      silent = true;
      desc = "Search recent files";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vu";
    action = "<cmd>lua Snacks.picker.undo()<cr>";
    options = {
      silent = true;
      desc = "Search undo history";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vd";
    action = "<cmd>lua Snacks.picker.git_diff()<cr>";
    options = {
      silent = true;
      desc = "Search git diffs";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vj";
    action = "<cmd>lua Snacks.picker.jumps()<cr>";
    options = {
      silent = true;
      desc = "Search jump list";
    };
  }
  {
    mode = ["n" "v"];
    key = "<leader>ad";
    action = "<cmd>lua avante_ask_diag()<CR>";
    options = {
      silent = true;
      desc = "Suggest fixes for diagnostics";
    };
  }
  {
    mode = ["n"];
    key = "<leader>an";
    action = "<cmd>:AvanteChatNew<CR>";
    options = {
      silent = true;
      desc = "Suggest fixes for diagnostics";
    };
  }
  {
    mode = ["n"];
    key = "<leader>vg";
    action = "<cmd>lua Snacks.lazygit()<cr>";
    options = {
      silent = true;
      desc = "Open Git interface";
    };
  }
  {
    mode = ["n"];
    key = "<leader>A";
    action = "<cmd>AerialNavToggle<cr>";
    options = {
      silent = true;
      desc = "Toggle code outline";
    };
  }
  {
    mode = ["n"];
    key = "<leader>z";
    action = "<cmd>lua Snacks.zen()<cr>";
    options = {
      silent = true;
      desc = "Toggle distraction‑free mode";
    };
  }
  {
    mode = ["n" "i" "v" "c" "t"];
    key = "<c-/>";
    action = "<cmd>lua Snacks.terminal()<cr>";
    options = {
      silent = true;
      desc = "Toggle terminal";
    };
  }
  {
    mode = ["n" "i"];
    key = "<c-a>";
    action = "<cmd>lua require('actions-preview').code_actions()<cr>";
    options = {
      silent = true;
      desc = "Toggle terminal";
    };
  }
  {
    mode = ["n"];
    key = "<leader>u";
    action = "<cmd>UndotreeToggle | UndotreeFocus <cr>";
    options = {
      silent = true;
      desc = "Toggle Undotree";
    };
  }
]
