---@class Logger
---@field trace fun(...: string)
---@field debug fun(...: string)
---@field info  fun(...: string)
---@field warn  fun(...: string)
---@field error fun(...: string)
---@field fatal fun(...: string)


---@enum (key) LogLevel
local LogLevel = {
    none  = 1,
    trace = 2,
    debug = 3,
    info  = 4,
    warn  = 5,
    error = 6,
    fatal = 7,
}

---@class LoggerOpts
---@field usePlenary boolean
---@field logLevel LogLevel

---@class LoggerBuilder
---@field __index self
---@field log Logger
---@field usePlenary boolean
---@field loglevel LogLevel

local LoggerBuilder = {}

---@type LoggerBuilder
---@param opts LoggerOpts
function LoggerBuilder:new(opts)
    local o = setmetatable({}, self)
    self.__index = self
    self.log = nil
    self.usePlenary = opts.usePlenary or false
    ---@type LogLevel
    self.logLevel = opts.logLevel or "trace"

    if self.usePlenary then
        self.log = self:GetPlenaryLogger(self.logLevel)
    else
        -- TODO: implementn level filter for vim_logger
        self.log = self:GetVimLogger(self.logLevel)
    end

    return o
end

function LoggerBuilder:__debug_reset()
    require("plenary.reload").reload_module("ltex_extra.utils.log")
end

---@param loglevel LogLevel
---@return Logger
function LoggerBuilder:GetPlenaryLogger(loglevel)
    return require("plenary.log").new { plugin = "ltex_extra", use_file = false, level = loglevel }
end

---@param loglevel LogLevel
---@return Logger
function LoggerBuilder:GetVimLogger(loglevel)
    ---@type Logger
    local vim_logger = {
        trace = function(...) vim.notify(..., vim.log.levels.TRACE) end,
        debug = function(...) vim.notify(..., vim.log.levels.DEBUG) end,
        info  = function(...) vim.notify(..., vim.log.levels.INFO) end,
        warn  = function(...) vim.notify(..., vim.log.levels.WARN) end,
        error = function(...) vim.notify(..., vim.log.levels.ERROR) end,
        fatal = function(...) vim.notify(..., vim.log.levels.ERROR) end
    }
    -- Overrides lower severities with a dummy function
    for key, severity in pairs(LogLevel) do
        if severity < LogLevel[loglevel] then
            vim_logger[key] = function(...) end
        end
    end
    return vim_logger
end

return LoggerBuilder
