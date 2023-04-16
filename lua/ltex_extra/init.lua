local M = {}

M.opts = {
    init_check = true,  -- boolean : whether to load dictionaries on startup
    load_langs = {},    -- table <string> : language for witch dictionaries will be loaded
    log_level = "none", -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
    path = "",          -- string : path to store dictionaries. Relative path uses current working directory
    server = nil,
}

local function register_lsp_commands()
    vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.src.commands-lsp").addToDictionary
    vim.lsp.commands["_ltex.hideFalsePositives"] = require("ltex_extra.src.commands-lsp").hideFalsePositives
    vim.lsp.commands["_ltex.disableRules"] = require("ltex_extra.src.commands-lsp").disableRules
end

local function call_ltex(server_opts)
    local ok, lspconfig = pcall(require, "lspconfig")
    if not ok then
        error("LTeX_extra: can't initialize ltex lspconfig module not found")
    end
    lspconfig["ltex"].setup(server_opts)
end

M.reload = function(...)
    require("ltex_extra.src.commands-lsp").reload(...)
end

M.setup = function(opts)
    opts = vim.tbl_deep_extend("force", M.opts, opts or {})

    opts.path = vim.fs.normalize(opts.path) .. "/"

    if opts.server then
        call_ltex(opts.server)
    end

    register_lsp_commands()

    if opts.init_check == true then
        M.reload(opts.load_langs)
    end

    M.opts = opts
end

return M
