if package.loaded.ltex_extra then
    vim.notify("Reinitializing ltex_extra", vim.log.levels.WARN)
    package.loaded.ltex_extra = nil
end

local ok, ltex_extra = pcall(require, "ltex_extra")
if not ok then
    vim.notify("Fail to load ltex_extra", vim.log.levels.WARN)
    return
end

-- TEST: https://github.com/barreiroleo/ltex_extra.nvim/issues/32
local opts = require("ltex_extra").opts
opts.path = vim.fn.expand("~") .. "/.local/share/ltex"
ltex_extra.setup(opts)
LOG(package.loaded.ltex_extra)
package.loaded.ltex_extra = nil

-- TEST: LTeX server init
local opts = require("ltex_extra").opts
opts.server = {}
ltex_extra.setup(opts)
LOG(package.loaded.ltex_extra)
package.loaded.ltex_extra = nil

-- TEST: Lsp commands
vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.commands-lsp").addToDictionary
vim.lsp.buf.execute_command({
    command = "_ltex.addToDictionary",
    arguments = {
        arguments = { {
            uri = "file:///home/leonardo/develop/ltex_extra.nvim/test/main.md",
            words = { ["es-AR"] = { "This" } }
        } },
        command = "_ltex.addToDictionary",
        title = "Add 'This' to dictionary"
    }
})
