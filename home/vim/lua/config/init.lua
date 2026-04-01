local M = {}

function M.setup()
  require("config.globals").setup()
  require("config.ui").setup()
  require("config.lsp").setup()
  require("config.telescope").setup()
  require("config.window_picker").setup()
  require("config.commands").setup()
end

return M
