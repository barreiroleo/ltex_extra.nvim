require("plenary.reload").reload_module("ltex_extra.utils.log")
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
---@field logLevel LogLevel
---@field usePlenary boolean
local default_opts = {
    logLevel = "trace",
    usePlenary = false
}


---@type Logger
---@param loglevel LogLevel
local function plenary_logger(loglevel)
    return require("plenary.log").new {
        plugin = "ltex_extra",
        use_file = false,
        level = loglevel
    }
end

---@type Logger
local vim_logger = {
    trace = function(...) vim.notify(..., vim.log.levels.TRACE) end,
    debug = function(...) vim.notify(..., vim.log.levels.DEBUG) end,
    info  = function(...) vim.notify(..., vim.log.levels.INFO) end,
    warn  = function(...) vim.notify(..., vim.log.levels.WARN) end,
    error = function(...) vim.notify(..., vim.log.levels.ERROR) end,
    fatal = function(...) vim.notify(..., vim.log.levels.ERROR) end
}


local Logger = {}

---@param opts LoggerOpts
---@return Logger
function Logger:new(opts)
    local logger = nil
    if opts.usePlenary then
        logger = plenary_logger(opts.logLevel)
    else
        logger = vim_logger
    end
    return setmetatable(logger, self)
end

local log = Logger:new(default_opts)
P(log)
log.trace("trace")
log.debug("debug")
log.info("info")
log.warn("warn")
log.error("error")
log.fatal("fatal")
