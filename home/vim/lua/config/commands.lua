local M = {}

function M.setup()
  vim.cmd([[
    cnoreabbrev <expr> W getcmdtype() ==# ':' && getcmdline() ==# 'W' ? 'w' : 'W'
    cnoreabbrev <expr> Wa getcmdtype() ==# ':' && getcmdline() ==# 'Wa' ? 'wa' : 'Wa'
    cnoreabbrev <expr> wA getcmdtype() ==# ':' && getcmdline() ==# 'wA' ? 'wa' : 'wA'
    cnoreabbrev <expr> WA getcmdtype() ==# ':' && getcmdline() ==# 'WA' ? 'wa' : 'WA'
  ]])
end

return M
