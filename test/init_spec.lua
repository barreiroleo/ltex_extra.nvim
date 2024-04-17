local log = require("plenary.log").new({
    plugin = "ltex tests",
    use_file = false,
    level = "trace"
})

describe("Setup and config:", function()
    local OPTS = require("ltex_extra.opts")

    before_each(
        function()
            log.trace("Reloading ltex_extra")
            -- require("plenary.reload").reload_module("ltex_extra", false)
            package.loaded.ltex_extra = nil
        end
    )

    it("Setup", function()
        log.trace("Setup")
        local status = require("ltex_extra").setup(OPTS.ltex_extra_opts)
        log.trace("Setup after")
        assert.equals(true, status)
    end)

    it("Registered commands", function()
        local registered_commands = vim.tbl_keys(vim.lsp.commands)
        local commands = {
            "_ltex.addToDictionary",
            "_ltex.disableRules",
            "_ltex.hideFalsePositives"
        }
        for _, key in ipairs(commands) do
            assert.equals(true, vim.tbl_contains(registered_commands, key))
        end
    end)
end)
