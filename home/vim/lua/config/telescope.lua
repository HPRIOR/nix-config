local M = {}

function M.setup()
  -- `defaults.mappings` is more reliable here than through the Nix options.
  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  })
end

return M
