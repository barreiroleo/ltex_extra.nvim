local log = require("ltex_extra.src.log")

local M = {}

local default_opts = {
    load_langs = { "es-AR", "en-US" },
    init_check = true,
    path = nil,
}

M.opts = {}

M.reload = function (...) require("ltex_extra.src.commands-lsp").reload(...) end

M.setup = function(opts)
    log.trace("Merge options")
    opts = opts or default_opts
    for key, value in pairs(default_opts) do
        if not opts[key] then opts[key] = value end
    end
    if opts.path then opts.path = opts.path .. "/" else opts.path = "" end
    M.opts = opts
    log.debug("Opts: " .. vim.inspect(M.opts))

    log.trace("Add commands to lsp")
    vim.lsp.commands['_ltex.addToDictionary']    = require("ltex_extra.src.commands-lsp").addToDictionary
    vim.lsp.commands['_ltex.hideFalsePositives'] = require("ltex_extra.src.commands-lsp").hideFalsePositives
    vim.lsp.commands['_ltex.disableRules']       = require("ltex_extra.src.commands-lsp").disableRules

    log.trace("Inital load files")
    if opts.init_check == true then
        M.reload(opts.load_langs)
    end
end

return M
