local function unload_ltex_extra()
    package.loaded.ltex_extra = nil
end

local OPTS = require("ltex_extra.opts")
OPTS.log_level = "trace"

describe("Setup and config:", function()
    it("Setup", function()
        unload_ltex_extra()
        local status = require("ltex_extra").setup(OPTS)
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
