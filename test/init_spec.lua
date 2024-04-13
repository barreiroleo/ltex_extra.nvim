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

    it("Setup", function()
        local status = require("ltex_extra").setup(M.ltex_extra_opts)
        assert.equals(true, status)
    end)
end)
