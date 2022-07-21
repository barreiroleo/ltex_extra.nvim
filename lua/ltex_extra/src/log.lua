local log = {}

log.init = function (level)
    if type(level) == "string" then
        local tmp_log = require("plenary.log").new {
            plugin = "ltex_extra",
            use_file = false,
            level = level
        }
        for k, v in pairs(tmp_log) do
          log[k] = v
        end
    elseif type(level) == "boolean" and level == true then
        local tmp_log = require("plenary.log").new {
            plugin = "ltex_extra",
            use_file = false,
            level = "warn"
        }
        for k, v in pairs(tmp_log) do
          log[k] = v
        end
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

    log.viminfo = function (...)
        vim.notify(...)
        log.info(...)
    end

    log.vimwarn = function (...)
        vim.notify(..., vim.log.levels.WARN)
        log.warn(...)
    end

    log.vimerror = function (...)
        vim.notify(..., vim.log.levels.ERROR)
        log.error(...)
    end

    return log
end

return log
