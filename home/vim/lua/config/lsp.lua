local M = {}

local ui = require("config.ui")

local function setup_handlers()
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = ui.floating_border,
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = ui.floating_border,
  })
end

local function setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = false,
    float = {
      border = ui.floating_border,
      style = "minimal",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "󰋼",
        [vim.diagnostic.severity.HINT] = "󰌵",
      },
    },
    underline = true,
    severity_sort = true,
  })
end

local function setup_ron_lsp()
  local lspconfig = require("lspconfig")
  local configs = require("lspconfig.configs")

  if not configs.ron_lsp then
    configs.ron_lsp = {
      default_config = {
        cmd = { vim.fn.expand("ron-lsp") },
        filetypes = { "ron" },
        root_dir = function(fname)
          return lspconfig.util.root_pattern("Cargo.toml", ".git")(fname) or vim.loop.cwd()
        end,
        settings = {},
      },
    }
  end

  lspconfig.ron_lsp.setup({})
end

local function setup_floating_preview()
  local original_open_floating_preview = vim.lsp.util.open_floating_preview

  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or ui.floating_border

    return original_open_floating_preview(contents, syntax, opts, ...)
  end
end

function M.setup()
  setup_handlers()
  setup_diagnostics()

  require("lspconfig.ui.windows").default_options = {
    border = ui.floating_border,
  }

  setup_ron_lsp()
  setup_floating_preview()
end

return M
