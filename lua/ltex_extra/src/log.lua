local log = {}

local function dummy_logs()
    local dummy   = function(...) return true end
    return {
        trace     = dummy,
        debug     = dummy,
        info      = dummy,
        warn      = dummy,
        error     = dummy,
        fatal     = dummy,
        fmt_trace = dummy,
        fmt_debug = dummy,
        fmt_info  = dummy,
        fmt_warn  = dummy,
        fmt_error = dummy,
        fmt_fatal = dummy,
    }
end

local function setup(level)
    if type(level) == "string" and level ~= "none" then
        local ok, _ = pcall(require, 'plenary.log')
        if not ok then
            vim.notify(
                "`ltex_extra` require `plenary` plugin for detailed logging",
                vim.log.levels.WARN
            )
            return dummy_logs()
        else
            return require("plenary.log").new {
                plugin = "ltex_extra",
                use_file = false,
                level = level
            }
        end
    else
        return dummy_logs()
    end
end

log = setup(package.loaded.ltex_extra.opts.log_level)

log.viminfo = function(...)
    vim.notify(...)
    log.info(...)
end

log.vimwarn = function(...)
    vim.notify(..., vim.log.levels.WARN)
    log.warn(...)
end

log.vimerror = function(...)
    vim.notify(..., vim.log.levels.ERROR)
    log.error(...)
end

return log
