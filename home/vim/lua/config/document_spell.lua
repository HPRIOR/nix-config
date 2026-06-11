local M = {}

local default_document_extensions = {
  "md",
  "markdown",
  "txt",
}

local document_extension_lookup = {}

-- 'spell' is window-local, so preserve the pre-document value per window.
local previous_spell_by_window = {}

local function build_extension_lookup(document_extensions)
  document_extension_lookup = {}

  for _, extension in ipairs(document_extensions) do
    document_extension_lookup[extension:lower()] = true
  end
end

local function is_document_buffer(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  local extension = vim.fn.fnamemodify(name, ":e"):lower()
  return document_extension_lookup[extension] == true
end

local function enable_document_spell()
  local window = vim.api.nvim_get_current_win()

  if not is_document_buffer(vim.api.nvim_get_current_buf()) then
    return
  end

  if previous_spell_by_window[window] == nil then
    previous_spell_by_window[window] = vim.wo.spell
  end

  vim.wo.spell = true
end

local function restore_spell()
  local window = vim.api.nvim_get_current_win()
  local previous_spell = previous_spell_by_window[window]

  if previous_spell == nil then
    return
  end

  vim.wo.spell = previous_spell
  previous_spell_by_window[window] = nil
end

function M.setup(opts)
  opts = opts or {}

  build_extension_lookup(opts.document_extensions or default_document_extensions)

  local group = vim.api.nvim_create_augroup("DocumentSpell", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = enable_document_spell,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    group = group,
    callback = restore_spell,
  })

  enable_document_spell()
end

return M
