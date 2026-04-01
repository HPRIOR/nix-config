local M = {}

M.floating_border = "rounded"

local border_colour = "#2D4F67"
local kanagawa_background = "#1f1f28"
local snacks_picker_background = "#16161D"

function M.setup()
  vim.api.nvim_set_hl(0, "BlinkCmpMenu", { background = "#223249" })

  -- This keeps floating borders aligned with the Kanagawa backdrop.
  vim.api.nvim_set_hl(0, "FloatBorder", {
    bg = kanagawa_background,
    fg = border_colour,
  })

  -- Snacks dims its picker background, so its border needs a separate fill.
  vim.api.nvim_set_hl(0, "SnacksPickerBorder", {
    bg = snacks_picker_background,
    fg = border_colour,
  })
end

return M
