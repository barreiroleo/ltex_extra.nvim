---@class PluginOpts
---@field init_check boolean Perform a scan inmediatelly after load the dictionaries
---@field load_langs string[] Languages to load. See LTeX definitions
---@field log_level LogLevel
---@field path string Path to store dictionaries. Relative to CWD or absolute
---@field server_start boolean Enable the call to ltex. Usefull for migration and test
---@field server_opts LSPServerOpts|nil

---@class LSPServerOpts
---@field on_attach function(client: any, bufnr: integer)
---@field capabilities any
---@field filetypes string[]
---@field settings table {ltex_opts}

---@class LtexOpts
---@field settings LtexSettings

---@class LtexSettings
---@field checkFrequency string
---@field language string
---@field additionalRules table {enablePickyRules: boolean, motherTongue: string}


---@type table{ltex_filetypes:string{}, ltex_opts:ltex_opts, ltex_extra_opts:Ltex_extra_opts}
local OPTS = {}

---@type string[]
OPTS.ltex_filetypes = { "bib", "markdown", "org", "plaintex", "rst", "rnoweb", "tex" }

---@type LtexOpts
OPTS.ltex_opts = {
    settings = {
        checkFrequency = "save",
        language = "es-AR",
        additionalRules = {
            enablePickyRules = true,
            motherTongue = "es-AR",
        },
    },
}
---@type PluginOpts
OPTS.ltex_extra_opts = {
    init_check = true,
    load_langs = { "es-AR", "en-US" },
    log_level = require("ltex_extra.test.setup").TRACE,
    path = ".ltex",
    server_start = false,
    server_opts = {
        on_attach = function(client, bufnr)
            print("Loading ltex from ltex_extra")
        end,
        filetypes = OPTS.ltex_filetypes,
        settings = {
            ltex = OPTS.ltex_opts,
        },
    },
}

return OPTS
