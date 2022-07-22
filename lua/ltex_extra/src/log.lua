local log = {}

log.init = function (level)
    if type(level) == "string" and level ~= "none" then
        if not pcall(require, "plenary.log") then
            vim.notify("`ltex_extra` requires the `plenary` plugin to display logs", vim.log.levels.WARN)
            return
        end
        local tmp_log = require("plenary.log").new {
            plugin = "ltex_extra",
            use_file = false,
            level = level
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
