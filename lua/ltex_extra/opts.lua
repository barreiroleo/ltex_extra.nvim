---@deprecated
---@alias server_start boolean
---@deprecated
---@alias server_opts LSPServerOpts|nil

---@class LtexExtraOpts
---@field init_check boolean Perform a scan inmediatelly after load the dictionaries
---@field load_langs string[] Languages to load. See LTeX definitions
---@field log_level LogLevel
---@field path string Path to store dictionaries. Relative to CWD or absolute
---@field server_start server_start Enable the call to ltex. Usefull for migration and test
---@field server_opts server_opts

---@class LSPServerOpts
---@field on_attach function(client: any, bufnr: integer)
---@field capabilities any
---@field filetypes string[]
---@field settings table {ltex: LtexSettings}
---@field root_dir any?

---@class LtexSettings
---@field checkFrequency string
---@field language string
---@field additionalRules table {enablePickyRules: boolean, motherTongue: string}

---@type LtexExtraOpts
local legacy_opts = {
    ---@deprecated
    init_check = true,
    load_langs = { "en-US" },
    log_level = "none",
    path = ".ltex",
    ---@deprecated
    server_start = false,
    ---@deprecated
    server_opts = nil,
    _use_plenary = false
}

---@type LtexExtraOpts
local tests_opts = {
    init_check = true,
    load_langs = { "es-AR", "en-US" },
    log_level = "info",
    path = ".ltex",
    server_start = false,
    server_opts = {
        -- selene: allow(unused_variable)
        on_attach = function(client, bufnr)
            print("Loading ltex from ltex_extra")
        end,
        filetypes = { "bib", "markdown", "org", "plaintex", "rst", "rnoweb", "tex" },
        settings = {
            ltex = {
                settings = {
                    checkFrequency = "save",
                    language = "es-AR",
                    additionalRules = {
                        enablePickyRules = true,
                        motherTongue = "es-AR",
                    },
                },
            },
        },
    },
}

return { legacy_def_opts = legacy_opts, tests_opts = tests_opts }
