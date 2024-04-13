---@enum LogLevel
local LogLevel = {
    NONE = "none",
    TRACE = "trace",
    DEBUG = "debug",
    INFO = "info",
    WARN = "warn",
    ERROR = "error",
    FATAL = "fatal",
}

---@class Ltex_extra_opts
---@field init_check boolean Perform a scan inmediatelly after load the dictionaries
---@field load_langs string[] Languages to load. See LTeX definitions
---@field log_level LogLevel
---@field path string Path to store dictionaries. Relative to CWD or absolute
---@field server_start boolean Enable the call to ltex. Usefull for migration and test
---@field server_opts server_opts|nil

---@class server_opts
---@field on_attach function(client: any, bufnr: integer)
---@field capabilities any
---@field filetypes string[]
---@field settings table {ltex_opts}

---@class ltex_opts
---@field settings ltex_settings

---@class ltex_settings
---@field checkFrequency string
---@field language string
---@field additionalRules table {enablePickyRules: boolean, motherTongue: string}

return LogLevel
