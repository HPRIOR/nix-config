local M = {}

function M.setup()
  Snacks.toggle.inlay_hints():map("<leader>Th")

  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.add({
      { "<leader>T", group = "Toggles" },
    })
  end
end

return M
