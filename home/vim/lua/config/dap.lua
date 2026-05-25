local M = {}

local uv = vim.uv or vim.loop
local Snacks = require("snacks")
local stale_breakpoint_prune_threshold = 10

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

local function breakpoint_store_dir()
	return vim.fs.joinpath(vim.fn.stdpath("data"), "dap-breakpoints")
end

local function breakpoint_store_path(session_name)
	local key = vim.fn.sha256(session_name ~= "" and session_name or vim.fn.getcwd())
	return vim.fs.joinpath(breakpoint_store_dir(), key .. ".json")
end

local function read_breakpoint_store(session_name)
	local path = breakpoint_store_path(session_name)
	local ok, lines = pcall(vim.fn.readfile, path)

	if not ok or #lines == 0 then
		return nil
	end

	local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	if decoded_ok and type(decoded) == "table" and type(decoded.breakpoints) == "table" then
		return decoded
	end

	vim.notify("DAP breakpoint store is invalid: " .. path, vim.log.levels.WARN)
	return nil
end

local function write_breakpoint_store(session_name, breakpoints)
	local dir = breakpoint_store_dir()
	local path = breakpoint_store_path(session_name)
	local ok_mkdir, mkdir_err = pcall(vim.fn.mkdir, dir, "p")

	if not ok_mkdir then
		vim.notify("DAP could not create breakpoint store " .. dir .. ": " .. tostring(mkdir_err), vim.log.levels.WARN)
		return
	end

	local encoded = vim.json.encode({
		version = 1,
		session_name = session_name,
		breakpoints = breakpoints,
	})
	local ok_write, write_err = pcall(vim.fn.writefile, { encoded }, path)

	if not ok_write then
		vim.notify("DAP could not save breakpoints to " .. path .. ": " .. tostring(write_err), vim.log.levels.WARN)
	end
end

local function read_file_line(path, line)
	if vim.fn.filereadable(path) ~= 1 or line < 1 then
		return nil
	end

	local ok, lines = pcall(vim.fn.readfile, path, "", line)
	if not ok or #lines < line then
		return nil
	end

	return lines[line]
end

local function normalized_line_text(text)
	return vim.trim(text or ""):gsub("%s+", " ")
end

-- Prefer loaded buffer contents so previews reflect unsaved edits at breakpoint locations.
local function get_file_line_text(bufnr, path, line)
	local text = ""

	if vim.api.nvim_buf_is_loaded(bufnr) then
		text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1] or ""
	else
		local ok, lines = pcall(vim.fn.readfile, path, "", line)
		if ok then
			text = lines[#lines] or ""
		end
	end

	return normalized_line_text(text)
end

local function breakpoint_id(breakpoint)
	return string.format("%s:%d", breakpoint.file, breakpoint.line)
end

local function breakpoint_sort_key(item)
	return string.format("%s:%08d", item.relative_file, item.line)
end

local function breakpoint_metadata_parts(breakpoint)
	local metadata = {}

	if breakpoint.condition and breakpoint.condition ~= "" then
		metadata[#metadata + 1] = "cond: " .. breakpoint.condition
	end

	if breakpoint.hitCondition and breakpoint.hitCondition ~= "" then
		metadata[#metadata + 1] = "hit: " .. breakpoint.hitCondition
	end

	if breakpoint.logMessage and breakpoint.logMessage ~= "" then
		metadata[#metadata + 1] = "log: " .. breakpoint.logMessage
	end

	return metadata
end

local function collect_breakpoint_snapshots()
	local breakpoints = require("dap.breakpoints").get()
	local snapshots = {}

	for bufnr, buf_breakpoints in pairs(breakpoints) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			local file = vim.api.nvim_buf_get_name(bufnr)

			if file ~= "" then
				file = vim.fn.fnamemodify(file, ":p")
				local display_file = relative_path(file)

				for _, breakpoint in ipairs(buf_breakpoints) do
					local line = breakpoint.line
					local line_text = get_file_line_text(bufnr, file, line)
					snapshots[#snapshots + 1] = {
						buf = bufnr,
						condition = breakpoint.condition,
						file = file,
						hitCondition = breakpoint.hitCondition,
						line = line,
						line_text = line_text,
						logMessage = breakpoint.logMessage,
						relative_file = display_file,
					}
				end
			end
		end
	end

	table.sort(snapshots, function(left, right)
		return breakpoint_sort_key(left) < breakpoint_sort_key(right)
	end)

	return snapshots
end

local function list_breakpoints()
	local items = {}

	for _, snapshot in ipairs(collect_breakpoint_snapshots()) do
		local metadata = breakpoint_metadata_parts(snapshot)
		local text = string.format("%s:%d  %s", snapshot.relative_file, snapshot.line, snapshot.line_text)

		if #metadata > 0 then
			text = text .. "  [" .. table.concat(metadata, "] [") .. "]"
		end

		items[#items + 1] = vim.tbl_extend("force", snapshot, {
			pos = { snapshot.line, 0 },
			text = text,
		})
	end

	return items
end

local function existing_breakpoint_ids()
	local ids = {}

	for _, snapshot in ipairs(collect_breakpoint_snapshots()) do
		ids[breakpoint_id(snapshot)] = true
	end

	return ids
end

local function collect_persisted_breakpoints()
	local items = {}

	for _, snapshot in ipairs(collect_breakpoint_snapshots()) do
		items[#items + 1] = {
			condition = snapshot.condition,
			file = snapshot.file,
			hitCondition = snapshot.hitCondition,
			line = snapshot.line,
			logMessage = snapshot.logMessage,
			source_text = snapshot.line_text,
			stale_count = 0,
		}
	end

	table.sort(items, function(left, right)
		return breakpoint_id(left) < breakpoint_id(right)
	end)

	return items
end

local function is_valid_persisted_breakpoint(breakpoint)
	if type(breakpoint) ~= "table" or type(breakpoint.file) ~= "string" or type(breakpoint.line) ~= "number" then
		return false
	end

	local current_line = read_file_line(breakpoint.file, breakpoint.line)
	if not current_line then
		return false
	end

	if breakpoint.source_text and breakpoint.source_text ~= "" then
		return normalized_line_text(current_line) == breakpoint.source_text
	end

	return true
end

local function set_breakpoint_at_location(breakpoint)
	local dap = require("dap")
	local original_buf = vim.api.nvim_get_current_buf()
	local original_win = vim.api.nvim_get_current_win()
	local bufnr = vim.fn.bufadd(breakpoint.file)

	-- nvim-dap only exposes breakpoint creation at the current cursor line.
	vim.fn.bufload(bufnr)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_win_set_cursor(0, { breakpoint.line, 0 })
	dap.set_breakpoint(breakpoint.condition, breakpoint.hitCondition, breakpoint.logMessage)

	if vim.api.nvim_win_is_valid(original_win) and vim.api.nvim_buf_is_valid(original_buf) then
		vim.api.nvim_set_current_win(original_win)
		vim.api.nvim_set_current_buf(original_buf)
	end
end

local function list_rust_target_profiles(target_dir)
	local profiles = {}

	for _, entry in ipairs(scandir(target_dir)) do
		if
			entry.entry_type == "directory"
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

		if
			(entry.entry_type == "file" or entry.entry_type == "link")
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

local function format_executable_item(item)
	return string.format("%s [%s] %s", item.name, item.profile, relative_path(item.path))
end

function M.pick_rust_executable()
	return coroutine.create(function(dap_run_co)
		local dap = require("dap")
		local cwd = vim.fn.getcwd()
		local executables = list_rust_executables(cwd)

		if #executables == 0 then
			vim.notify(
				"DAP could not find any executables under " .. vim.fs.joinpath(cwd, "target"),
				vim.log.levels.WARN
			)
			coroutine.resume(dap_run_co, dap.ABORT)
			return
		end

		Snacks.picker.select(executables, {
			prompt = "Select executable: ",
			format_item = format_executable_item,
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

function M.pick_breakpoints()
	local breakpoints = list_breakpoints()

	if #breakpoints == 0 then
		vim.notify("DAP has no breakpoints to show", vim.log.levels.WARN)
		return
	end

	Snacks.picker({
		title = "Breakpoints",
		finder = function()
			return breakpoints
		end,
		format = "text",
		preview = "file",
		confirm = "jump",
		layout = {
			preset = "default",
		},
	})
end

function M.save_breakpoints(session_name)
	session_name = session_name or ""

	local stored = read_breakpoint_store(session_name)
	local breakpoints = collect_persisted_breakpoints()
	local seen = {}

	for _, breakpoint in ipairs(breakpoints) do
		seen[breakpoint_id(breakpoint)] = true
	end

	if stored then
		for _, breakpoint in ipairs(stored.breakpoints) do
			local stale_count = tonumber(breakpoint.stale_count) or 0

			if
				stale_count > 0
				and stale_count < stale_breakpoint_prune_threshold
				and type(breakpoint.file) == "string"
				and type(breakpoint.line) == "number"
				and not seen[breakpoint_id(breakpoint)]
			then
				breakpoints[#breakpoints + 1] = breakpoint
				seen[breakpoint_id(breakpoint)] = true
			end
		end
	end

	write_breakpoint_store(session_name, breakpoints)
end

function M.restore_breakpoints(session_name)
	session_name = session_name or ""

	local stored = read_breakpoint_store(session_name)
	if not stored then
		return
	end

	local ids = existing_breakpoint_ids()
	local updated = {}
	local changed = false

	for _, breakpoint in ipairs(stored.breakpoints) do
		local stale_count = tonumber(breakpoint.stale_count) or 0

		if is_valid_persisted_breakpoint(breakpoint) then
			breakpoint.stale_count = 0

			if not ids[breakpoint_id(breakpoint)] then
				set_breakpoint_at_location(breakpoint)
				ids[breakpoint_id(breakpoint)] = true
			end

			updated[#updated + 1] = breakpoint
		else
			breakpoint.stale_count = stale_count + 1
			changed = true

			if breakpoint.stale_count < stale_breakpoint_prune_threshold then
				updated[#updated + 1] = breakpoint
			end
		end
	end

	if changed then
		write_breakpoint_store(session_name, updated)
	end
end

return M
