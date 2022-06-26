-- local pathOfThisFile = ... -- pathOfThisFile is now 'lib.foo.bar'
-- local folderPath = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'
-- local command_handler = require(folderPath .. "src.commands-lsp")

local M = {}

local default_opts = {
    load_langs = {"es-AR", "en-US"},
    init_check = false,
}

M.opts = {}

M.setup = function (opts)
    M.opts = opts or default_opts
    for key, value in pairs(default_opts) do
        if not M.opts[key] then
            M.opts[key] = value
        end
    end

    vim.lsp.buf.execute_command = require("ltex_extra.src.commands-lsp").commandHandler
    if opts.init_check == true then
        require("ltex_extra.src.commands-lsp").updateConfigFull(opts.load_langs)
    end
end

return M
