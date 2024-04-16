local log = require("plenary.log").new({
    plugin = "ltex tests",
    use_file = false,
    level = "trace"
})
describe("Setup and config:", function()
    local LOG = require("ltex_extra.test.setup")
    local M = {}

    ---@type string[]
    M.ltex_filetypes = { "bib", "markdown", "org", "plaintex", "rst", "rnoweb", "tex" }

    ---@type ltex_opts
    M.ltex_opts = {
        settings = {
            checkFrequency = "save",
            language = "es-AR",
            additionalRules = {
                enablePickyRules = true,
                motherTongue = "es-AR",
            },
        },
    }
    ---@type Ltex_extra_opts
    M.ltex_extra_opts = {
        init_check = true,
        load_langs = { "es-AR", "en-US" },
        log_level = LOG.TRACE,
        path = ".ltex",
        server_start = false,
        server_opts = {
            on_attach = function(client, bufnr)
                print("Loading ltex from ltex_extra")
            end,
            filetypes = M.ltex_filetypes,
            settings = {
                ltex = M.ltex_opts,
            },
        },
    }

    before_each(
        function()
            log.trace("Reloading ltex_extra")
            -- require("plenary.reload").reload_module("ltex_extra", false)
            package.loaded.ltex_extra = nil
        end
    )

    it("Setup", function()
        log.trace("Setup")
        local status = require("ltex_extra").setup(M.ltex_extra_opts)
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
