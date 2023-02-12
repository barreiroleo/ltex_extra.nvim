local default_opts = {
    load_langs = {}, -- table <string> : language for witch dictionaries will be loaded
    init_check = true, -- boolean : whether to load dictionaries on startup
    path = nil, -- string : path to store dictionaries. Relative path uses current working directory
    log_level = "none", -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
    server = {},
}

local M = {}

M.opts = {}

M.reload = function(...)
    require("ltex_extra.src.commands-lsp").reload(...)
end

M.setup = function(opts)
    local log = require("ltex_extra.src.log")

    if opts.path then
        opts.path = vim.fs.normalize(opts.path .. "/")
    else
        opts.path = ""
    end

    if not opts.server then
        opts.server = {}
    end
    local on_attach = opts.server.on_attach
    opts.server.on_attach = function(...)
        log.trace("Add commands to lsp")
        vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.src.commands-lsp").addToDictionary
        vim.lsp.commands["_ltex.hideFalsePositives"] = require("ltex_extra.src.commands-lsp").hideFalsePositives
        vim.lsp.commands["_ltex.disableRules"] = require("ltex_extra.src.commands-lsp").disableRules
        if on_attach then
            on_attach(...)
        end
        log.trace("Inital load files")
        if M.opts.init_check == true then
            M.reload(M.opts.load_langs)
        end
    end

    M.opts = vim.tbl_deep_extend("force", default_opts, opts)
    log.debug("Opts: " .. vim.inspect(M.opts))

    if require("ltex_extra.src.commands-lsp").catch_ltex() then
        vim.notify(
            [[Newer version of LTeX_extra will set up lspconfig for you.
The old pattern of setting up in on_attach is deprecated.
Please remove any manual setup of ltex server.]],
            vim.log.levels.WARN
        )
        opts.server.on_attach()
        return
    end

    local ok, lspconfig = pcall(require, "lspconfig")
    if not ok then
        vim.notify("LTeX_extra setup terminates because lspconfig module is not found", vim.log.levels.ERROR)
        return
    end

    log.trace("Setup lspconfig")
    lspconfig["ltex"].setup(opts.server)
end

return M
