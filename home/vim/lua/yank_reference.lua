local M = {}

local function trim(text)
  if type(text) ~= "string" then
    return nil
  end

  local trimmed = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if trimmed == "" then
    return nil
  end

  return trimmed
end

local function symbol_names(symbols)
  local parts = {}

  for _, symbol in ipairs(symbols or {}) do
    local name = trim(symbol.name)
    if name then
      table.insert(parts, name)
    end
  end

  return parts
end

local function get_aerial_hierarchy()
  local ok, aerial = pcall(require, "aerial")
  if not ok or type(aerial.get_location) ~= "function" then
    return nil
  end

  if type(aerial.sync_load) == "function" then
    pcall(aerial.sync_load)
  end

  local location_ok, location = pcall(aerial.get_location, false)
  if not location_ok then
    return nil
  end

  local parts = symbol_names(location)
  if #parts > 0 then
    return parts
  end

  return nil
end

local function get_dropbar_hierarchy()
  local ok, sources = pcall(require, "dropbar.sources")
  if not ok then
    return nil
  end

  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)

  for _, source in ipairs({ sources.lsp, sources.treesitter }) do
    if type(source) == "table" and type(source.get_symbols) == "function" then
      local symbols_ok, symbols = pcall(source.get_symbols, buf, win, cursor)
      if symbols_ok then
        local parts = symbol_names(symbols)
        if #parts > 0 then
          return parts
        end
      end
    end
  end

  return nil
end

local function get_hierarchy()
  return get_aerial_hierarchy() or get_dropbar_hierarchy() or {}
end

local function get_reference()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  local col = cursor[2] + 1

  if filepath == "" then
    filepath = "[No Name]"
  else
    filepath = vim.fn.fnamemodify(filepath, ":p")
  end

  local reference = string.format("%s line: %d col: %d", filepath, line, col)
  local hierarchy = get_hierarchy()

  if #hierarchy > 0 then
    reference = string.format("%s %s", reference, table.concat(hierarchy, " |> "))
  end

  return reference
end

function M.yank()
  local reference = get_reference()

  vim.fn.setreg('"', reference)
  pcall(vim.fn.setreg, "+", reference)

  vim.notify("Yanked reference: " .. reference, vim.log.levels.INFO, {
    title = "Reference Yank",
  })
end

_G.YankReference = M

