local log = require("ltex_extra.utils.log")
local uv = vim.loop

local M = {}

-- Sets the path where ltex files should be located.
M.set_path = function()
    log.trace("Setting ltex files path")
    local path = package.loaded.ltex_extra.opts.path
    path = vim.fs.normalize(path)
    if M.check_dir(path) then
        -- Get the fullpath in case it is relative
        local realpath = uv.fs_realpath(path)
        if realpath then
            M.path = vim.fs.normalize(realpath) .. "/"
            log.info("Set ltex file path to", M.path)
            return
        end
    end
    log.vimerror("Failed to set path to " .. package.loaded.ltex_extra.opts.path)
end

-- Initialises the file watcher
M.init_watcher = function()
    log.trace("Starting file watcher on directory", M.path)
    if not M.watcher then
        -- fs_poll works better than fs_event because it does not trigger when
        -- appending to existing files and works on both windows and linux
        -- fs_event also has a tendency to spam events
        M.watcher = uv.new_fs_poll()
        M.watcher_skip = 0
    end

    -- Stop watcher on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            if M.watcher and not M.watcher:is_closing() then
                M.watcher:stop()
            end
        end,
    })

    -- The file watcher only works if the directory already exists when it's
    -- started
    if not M.check_dir(M.path) then
        return false
    end

    -- Poll with 5 second interval
    M.watcher:start(M.path, 5000, vim.schedule_wrap(M.watcher_callback))
end

-- Called when the file watcher detects a change
M.watcher_callback = function(err, _, _)
    log.trace("Detected file watcher change")
    if err then
        log.vimerror("File watcher error:", err)
    end
    if M.watcher_skip > 0 then
        M.watcher_skip = M.watcher_skip - 1
        log.debug("Ignoring file watcher change")
        return
    end
    log.info("Invoking reload from file watcher change")
    require("ltex_extra").reload()
end

-- Returns the filename for a type and lang required.
M.joinPath = function(type, lang)
    return vim.fs.normalize(M.path .. table.concat({ "ltex", type, lang, "txt" }, "."))
end

-- Check if path exist. Apply for files and dirs.
-- Will also return true for relative paths.
M.path_exist = function(path)
    log.trace("Checking path", path)
    return uv.fs_stat(path) ~= nil
end

-- Make a specified directory and check if created succesfully.
M.mkdir = function(dirname)
    log.trace("Making dir", dirname)
    local ok, err = uv.fs_mkdir(dirname, 484)
    if not ok then
        log.vimwarn("Failed making directory:", err)
        return false
    else
        log.info("Directory made successfully", dirname)
        return true
    end
end

-- Check if a dir exist, if not, try to making it.
M.check_dir = function(dirname)
    log.trace("Checking dir", dirname)
    local stat = uv.fs_stat(dirname)
    if not stat then
        log.info(dirname .. " not found, making it")
        if M.mkdir(dirname) then
            return true
        end
        return false
    end
    if stat.type ~= "directory" then
        log.vimwarn(dirname .. " is not a directory")
        return false
    end
    return true
end

-- Write specified content into a file.
M.writeFile = function(filename, lines)
    log.trace("Writing", filename, lines)
    if package.loaded.ltex_extra.opts.file_watcher and not M.path_exist(filename) then
        -- As this is creating a new file, it will trigger the file watcher
        -- Increment the skip counter to ensure we don't reload config
        M.watcher_skip = M.watcher_skip + 1
    end
    local fd, err = uv.fs_open(filename, "a+", 420)
    if not fd then
        log.vimerror("Failed to open file " .. filename .. ": " .. err)
        return
    end
    uv.fs_write(fd, table.concat(lines, "\n") .. "\n")
    uv.fs_close(fd)
end

-- Export ltex data depends on the type and lang especified.
M.exportFile = function(type, lang, lines)
    log.trace("Exporting", type, lang, lines)
    local filename = M.joinPath(type, lang)
    if M.check_dir(M.path) then
        M.writeFile(filename, lines)
    else
        log.vimwarn("Fail export " .. filename)
    end
end

-- Check if a file uses carriage returns in line feeds and, if so, remove them.
M.check_line_feeds = function(filename, data)
    log.trace("Checking if file uses carriage returns in line feeds")
    local first_line = data:match(".*[^\n]")
    if first_line and first_line:find("\r") then
        log.debug("Found windows line feeds, replacing file contents")
        data = data:gsub("\r\n", "\n")

        -- Overwrite file with sanitized data
        local fd, err = uv.fs_open(filename, "w", 420)
        if not fd then
            log.vimerror("Failed to open file " .. filename .. ": " .. err)
            return data
        end
        uv.fs_write(fd, data)
        uv.fs_close(fd)
    end
    return data
end

-- Return the content of a required file
M.readFile = function(filename)
    log.trace("Reading", filename)
    local fd, err = uv.fs_open(filename, "r", 420)
    if not fd then
        log.vimerror("Failed to open file " .. filename .. ": " .. err)
        return {}
    end
    local stat = uv.fs_fstat(fd)
    if not stat then
        return {}
    end
    local data = uv.fs_read(fd, stat.size)
    uv.fs_close(fd)
    data = M.check_line_feeds(filename, data)
    return data and vim.split(data, "\n", { trimempty = true }) or {}
end

-- Return the content of a required type and lang.
-- If the file doesn't exist, return empty table.
M.loadFile = function(type, lang)
    log.trace("Loading", type, lang)
    local content = {}
    local filename = M.joinPath(type, lang)
    if M.path_exist(filename) then
        content = M.readFile(filename)
    else
        content = {}
    end
    log.debug(vim.inspect(content))
    return content
end

return M
