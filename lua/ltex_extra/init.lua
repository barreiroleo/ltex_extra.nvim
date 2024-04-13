local M = {}

M.opts = {
    init_check = true,        -- boolean : whether to load dictionaries on startup
    load_langs = { "en-US" }, -- table <string> : language for witch dictionaries will be loaded
    log_level = "none",       -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
    path = "",                -- string : path to store dictionaries. Project root or current working directory
    server_start = true,      -- boolean : Enable the call to ltex. Usefull for migration and test
    server_opts = nil,
}

local function register_lsp_commands()
    vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.commands-lsp").addToDictionary
    vim.lsp.commands["_ltex.hideFalsePositives"] = require("ltex_extra.commands-lsp").hideFalsePositives
    vim.lsp.commands["_ltex.disableRules"] = require("ltex_extra.commands-lsp").disableRules
end

local function call_ltex(server_opts)
    local ok, lspconfig = pcall(require, "lspconfig")
    if not ok then
        error("LTeX_extra: can't initialize ltex lspconfig module not found")
    end
    lspconfig["ltex"].setup(server_opts)
end

local function first_load()
    if M.opts.init_check == true then
        M.reload(M.opts.load_langs)
    end
end

local function extend_ltex_on_attach(on_attach)
    if on_attach then
        return function(...)
            on_attach(...)
            first_load()
        end
    else
        return first_load
    end
end

M.reload = function(...)
    require("ltex_extra.commands-lsp").reload(...)
end

M.setup = function(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
    M.opts.path = vim.fs.normalize(M.opts.path)

    register_lsp_commands()

    if M.opts.server_opts and M.opts.server_start then
        M.opts.server_opts.on_attach = extend_ltex_on_attach(M.opts.server_opts.on_attach)
        call_ltex(M.opts.server_opts)
    else
        first_load()
    end
    return true
end

return M
