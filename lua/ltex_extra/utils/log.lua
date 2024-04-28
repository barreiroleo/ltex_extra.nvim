---@class Logger
---@field trace fun(...: string)
---@field debug fun(...: string)
---@field info  fun(...: string)
---@field warn  fun(...: string)
---@field error fun(...: string)
---@field fatal fun(...: string)

---@class LoggerOpts
---@field logLevel LogLevel
---@field _use_plenary boolean

---@class LoggerBuilder
---@field log Logger
---@field _use_plenary boolean
---@field loglevel LogLevel

---@enum (key) LogLevel
local LogLevels = {
    none  = 0,
    fatal = 1,
    error = 2,
    warn  = 3,
    info  = 4,
    debug = 5,
    trace = 6,
}


local LoggerBuilder = {}

---@type LoggerBuilder
---@param opts LoggerOpts
function LoggerBuilder:new(opts)
    ---@type LoggerBuilder
    self.__index = self
    ---@type Logger
    self.log = nil
    ---@type boolean
    self._use_plenary = opts._use_plenary
    self.logLevel = opts.logLevel or "trace"

    if self._use_plenary then
        self.log = self:GetPlenaryLogger(self.logLevel)
    else
        self.log = self:GetVimLogger(self.logLevel)
    end

    return setmetatable({}, self)
end

function LoggerBuilder:__debug_reset()
    require("plenary.reload").reload_module("ltex_extra.utils.log")
    require("plenary.reload").reload_module("plenary.log")
end

---@param loglevel LogLevel
---@return Logger
function LoggerBuilder:GetPlenaryLogger(loglevel)
    local opts = { plugin = "ltex_extra", level = loglevel, use_console = "async" }
    return require("plenary.log").new(opts)
end

---@type Logger
local VimLogger = {
    trace = vim.schedule_wrap(function(...) vim.notify("[Ltex_extra] [TRACE] " .. ..., vim.log.levels.TRACE) end),
    debug = vim.schedule_wrap(function(...) vim.notify("[Ltex_extra] [DEBUG] " .. ..., vim.log.levels.DEBUG) end),
    info  = vim.schedule_wrap(function(...) vim.notify("[Ltex_extra] [INFO] " .. ..., vim.log.levels.INFO) end),
    warn  = vim.schedule_wrap(function(...) vim.notify("[Ltex_extra] [WARN] " .. ..., vim.log.levels.WARN) end),
    error = vim.schedule_wrap(function(...) vim.notify("[Ltex_extra] [ERROR] " .. ..., vim.log.levels.ERROR) end),
    fatal = vim.schedule_wrap(function(...) vim.notify("[Ltex_extra] [FATAL] " .. ..., vim.log.levels.ERROR) end)
}

---@param severity string
---@return Logger
function LoggerBuilder:GetVimLogger(severity)
    -- Overrides lower severities with a dummy function
    for index, _ in pairs(VimLogger) do
        if LogLevels[severity] < LogLevels[index] then
            VimLogger[index] = function() end
        end
    end
    return VimLogger
end

return LoggerBuilder
