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

local function get_location()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local cursor = vim.api.nvim_win_get_cursor(0)

  if filepath == "" then
    filepath = "[No Name]"
  else
    filepath = vim.fn.fnamemodify(filepath, ":p")
  end

  return {
    filepath = filepath,
    line = cursor[1],
    col = cursor[2] + 1,
    hierarchy = get_hierarchy(),
  }
end

local function format_file(location)
  return location.filepath
end

local function format_file_with_position(location)
  return string.format("%s line: %d col: %d", location.filepath, location.line, location.col)
end

local function format_full_reference(location)
  local reference = format_file_with_position(location)

  if #location.hierarchy > 0 then
    reference = string.format("%s %s", reference, table.concat(location.hierarchy, " |> "))
  end

  return reference
end

local function yank(value, label)
  vim.fn.setreg('"', value)
  pcall(vim.fn.setreg, "+", value)

  vim.notify(string.format("Yanked %s: %s", label, value), vim.log.levels.INFO, {
    title = "Reference Yank",
  })
end

function M.yank_file()
  yank(format_file(get_location()), "file")
end

function M.yank_file_with_position()
  yank(format_file_with_position(get_location()), "file location")
end

function M.yank_full()
  yank(format_full_reference(get_location()), "reference")
end

M.yank = M.yank_full

_G.YankReference = M

return M
