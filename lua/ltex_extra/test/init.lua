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
-- LOG(package.loaded.ltex_extra)
package.loaded.ltex_extra = nil

-- TEST: LTeX server init
local opts = require("ltex_extra").opts
opts.server = {}
ltex_extra.setup(opts)
LOG(package.loaded.ltex_extra)
package.loaded.ltex_extra = nil
