local def_opts = require("ltex_extra.opts").tests_opts

describe("Setup and API:", function()
    before_each(function()
        require("ltex_extra").__debug_reset()
        require("ltex_extra.utils.log"):__debug_reset()
    end)

    it("Setup", function()
        local status = require("ltex_extra").setup(def_opts)
        assert(status ~= nil, "Setup didn't finish its execution")
    end)

    it("Get opts", function()
        require("ltex_extra").setup(def_opts)
        local opts = require("ltex_extra").__get_opts()
        assert(opts ~= nil, "Cannot reach the ltex opts")
    end)

    it("Registered commands", function()
        require("ltex_extra").setup(def_opts)
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
