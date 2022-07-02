local debug = false

local log = {}

if debug then
    log = require("plenary.log").new {
        plugin = "ltex_extra",
        use_file = false,
        level = "trace"
    }
else
    local dummy = function (...) return true end
    log.trace     = dummy
    log.debug     = dummy
    log.info      = dummy
    log.warn      = dummy
    log.error     = dummy
    log.fatal     = dummy
    log.fmt_trace = dummy
    log.fmt_debug = dummy
    log.fmt_info  = dummy
    log.fmt_warn  = dummy
    log.fmt_error = dummy
    log.fmt_fatal = dummy
end


-- local default_config = {
--   -- Name of the plugin. Prepended to log messages
--   plugin = "plenary",
--
--   -- Should print the output to neovim while running
--   -- values: 'sync','async',false
--   use_console = "async",
--
--   -- Should highlighting be used in console (using echohl)
--   highlights = true,
--
--   -- Should write to a file
--   use_file = true,
--
--   -- Should write to the quickfix list
--   use_quickfix = false,
--
--   -- Any messages above this level will be logged.
--   level = p_debug and "debug" or "info",
--
--   -- Level configuration
--   modes = {
--     { name = "trace", hl = "Comment" },
--     { name = "debug", hl = "Comment" },
--     { name = "info", hl = "None" },
--     { name = "warn", hl = "WarningMsg" },
--     { name = "error", hl = "ErrorMsg" },
--     { name = "fatal", hl = "ErrorMsg" },
--   },
--
--   -- Can limit the number of decimals displayed for floats
--   float_precision = 0.01,
-- }

return log
