local M = {}

local uv = vim.uv or vim.loop
local Snacks = require("snacks")

local function is_executable(path)
  return vim.fn.isdirectory(path) == 0 and vim.fn.executable(path) == 1
end

local ignored_target_profile_dirs = {
  [".fingerprint"] = true,
  build = true,
  deps = true,
  doc = true,
  examples = true,
  incremental = true,
  package = true,
  tmp = true,
}

-- Only offer top-level Cargo app binaries from each profile directory.
local function is_rust_app_binary(path)
  local name = vim.fs.basename(path)

  if name:match("^lib.*%.dylib$") or name:match("^lib.*%.so[%d%.]*$") or name:match("^lib.*%.a$") then
    return false
  end

  return true
end

local function scandir(dir)
  local handle = uv.fs_scandir(dir)
  if not handle then
    return {}
  end

  local entries = {}

  while true do
    local name, entry_type = uv.fs_scandir_next(handle)
    if not name then
      break
    end

    entries[#entries + 1] = {
      entry_type = entry_type,
      name = name,
      path = vim.fs.joinpath(dir, name),
    }
  end

  return entries
end

local function relative_path(path)
  return vim.fn.fnamemodify(path, ":.")
end

local function list_rust_target_profiles(target_dir)
  local profiles = {}

  for _, entry in ipairs(scandir(target_dir)) do
    if entry.entry_type == "directory"
      and not ignored_target_profile_dirs[entry.name]
      and not entry.name:match("^%.")
    then
      profiles[#profiles + 1] = entry.name
    end
  end

  table.sort(profiles)

  return profiles
end

local function add_executables(items, seen, dir, profile)
  if vim.fn.isdirectory(dir) ~= 1 then
    return
  end

  for _, entry in ipairs(scandir(dir)) do
    local path = entry.path

    if (entry.entry_type == "file" or entry.entry_type == "link")
      and is_executable(path)
      and is_rust_app_binary(path)
      and not seen[path]
    then
      seen[path] = true
      items[#items + 1] = {
        name = vim.fs.basename(path),
        path = path,
        profile = profile,
      }
    end
  end
end

local function executable_sort_key(item)
  local profile_rank = item.profile == "debug" and 0 or item.profile == "release" and 1 or 2
  return string.format("%d:%s:%s:%s", profile_rank, item.profile, item.name, item.path)
end

local function list_rust_executables(cwd)
  local target_dir = vim.fs.joinpath(cwd, "target")
  local items = {}
  local seen = {}

  for _, profile in ipairs(list_rust_target_profiles(target_dir)) do
    add_executables(items, seen, vim.fs.joinpath(target_dir, profile), profile)
  end

  table.sort(items, function(left, right)
    return executable_sort_key(left) < executable_sort_key(right)
  end)

  return items
end

local function format_item(item)
  return string.format("%s [%s] %s", item.name, item.profile, relative_path(item.path))
end

function M.pick_rust_executable()
  return coroutine.create(function(dap_run_co)
    local dap = require("dap")
    local cwd = vim.fn.getcwd()
    local executables = list_rust_executables(cwd)

    if #executables == 0 then
      vim.notify("DAP could not find any executables under " .. vim.fs.joinpath(cwd, "target"), vim.log.levels.WARN)
      coroutine.resume(dap_run_co, dap.ABORT)
      return
    end

    Snacks.picker.select(executables, {
      prompt = "Select executable: ",
      format_item = format_item,
      snacks = {
        layout = {
          preset = "select",
        },
      },
    }, function(choice)
      if not choice then
        coroutine.resume(dap_run_co, dap.ABORT)
        return
      end

      local path = vim.fn.fnamemodify(choice.path, ":p")
      vim.notify("DAP launching executable: " .. path, vim.log.levels.INFO)

      if not is_executable(path) then
        vim.notify("DAP executable does not exist or is not executable: " .. path, vim.log.levels.ERROR)
        coroutine.resume(dap_run_co, dap.ABORT)
        return
      end

      coroutine.resume(dap_run_co, path)
    end)
  end)
end

return M
