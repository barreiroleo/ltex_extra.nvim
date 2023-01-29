local M = {}

local default_opts = {
    load_langs = { "es-AR", "en-US" }, -- table <string> : language for witch dictionaries will be loaded
    init_check = true, -- boolean : whether to load dictionaries on startup
    path = nil, -- string : path to store dictionaries. Relative path uses current working directory
    log_level = "none", -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
}

M.opts = {}

M.reload = function(...) require("ltex_extra.src.commands-lsp").reload(...) end

M.setup = function(opts)
    if opts.path then opts.path = vim.fs.normalize(opts.path .. "/") else opts.path = "" end
    M.opts = vim.tbl_deep_extend('force', default_opts, opts)

    local log = require("ltex_extra.src.log")
    log.debug("Opts: " .. vim.inspect(M.opts))

    log.trace("Add commands to lsp")
    vim.lsp.commands['_ltex.addToDictionary']    = require("ltex_extra.src.commands-lsp").addToDictionary
    vim.lsp.commands['_ltex.hideFalsePositives'] = require("ltex_extra.src.commands-lsp").hideFalsePositives
    vim.lsp.commands['_ltex.disableRules']       = require("ltex_extra.src.commands-lsp").disableRules

    log.trace("Inital load files")
    if M.opts.init_check == true then
        M.reload(M.opts.load_langs)
    end
end

return M
