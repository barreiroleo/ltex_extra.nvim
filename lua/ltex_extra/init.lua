local log = require("ltex_extra.src.log")

local M = {}

local default_opts = {
    load_langs = { "es-AR", "en-US" },
    init_check = true,
}

M.opts = {}

M.setup = function(opts)
    log.trace("Merge options")
    M.opts = opts or default_opts
    for key, value in pairs(default_opts) do
        if not M.opts[key] then
            M.opts[key] = value
        end
    end

    log.trace("Add commands to lsp")
    vim.lsp.commands['_ltex.addToDictionary']    = require("ltex_extra.src.commands-lsp").addToDictionary
    vim.lsp.commands['_ltex.hideFalsePositives'] = require("ltex_extra.src.commands-lsp").hideFalsePositives
    vim.lsp.commands['_ltex.disableRules']       = require("ltex_extra.src.commands-lsp").disableRules

    log.trace("Inital load files")
    if opts.init_check == true then
        require("ltex_extra.src.commands-lsp").updateConfigFull(opts.load_langs)
    end
end

return M

-- Dev notes:
--
-- Dummy functions for test vim.lsp.commands
-- local dummy_calls = 0
-- local dummy_cmd = function()
--     print(dummy_calls)
--     dummy_calls = dummy_calls + 1
--     print(dummy_calls)
-- end

-- Inspect function for arguments. Doesn't work after nvim 0.7.
-- local orig_execute_command = vim.lsp.buf.execute_command
-- vim.lsp.buf.execute_command = function (command)
--     print(vim.inspect(command))
--     orig_execute_command(command)
-- end
