local log = require("ltex_extra.utils.log").log
local config_path = require("ltex_extra").__get_opts().path
local uv = vim.loop

local M = {}

-- Returns path to the directory where ltex files should be located.
M.path = function()
    -- Handle windows path with drive letter like C:\
    if config_path:match("^%a:") then
        local absolutePath = vim.fs.normalize(config_path) .. "\\"
        log.trace("Returning absolute Windows path: " .. absolutePath)
        return absolutePath
    end

    -- Check if the path is absolute for Linux
    if config_path:sub(1, 1) == "/" then
        return config_path .. "/"
    end

    -- TODO: Get the root_dir from ltex client when do the setup
    -- local server_opts = require("ltex_extra").__get_opts().server_opts
    -- local root_dir = server_opts and server_opts.root_dir or uv.cwd()
    local root_dir = uv.cwd()

    -- Assume relative path and append to the root dir.
    return vim.fs.normalize(root_dir .. "/" .. config_path) .. "/"
end


-- Returns the filename for a type and lang required.
M.joinPath = function(type, lang)
    return vim.fs.normalize(M.path() .. table.concat({ "ltex", type, lang, "txt" }, "."))
end

-- Check if path exist. Apply for files and dirs.
M.path_exist = function(path)
    log.trace("Checking path ", path)
    return uv.fs_stat(path) ~= nil
end

-- Make a specified directory and check if created succesfully.
M.mkdir = function(dirname)
    log.trace("Making dir ", dirname)
    local ok, err = uv.fs_mkdir(dirname, 484)
    if not ok then
        log.warn("Failed making directory: " .. err)
        return false
    else
        log.info("Directory made succesfully ", dirname)
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
    end
    ---@diagnostic disable-next-line: need-check-nil
    if stat.type ~= "directory" then
        log.warn(dirname .. " is not a directory")
        return false
    end
    return true
end

-- Write specified content into a file.
M.writeFile = function(filename, lines)
    log.trace("Writing ", filename, lines)
    local fd, err = uv.fs_open(filename, "a+", 420)
    if not fd then
        log.error("Failed to open file " .. filename .. ": " .. err)
        return
    end
    uv.fs_write(fd, table.concat(lines, "\n") .. "\n")
    uv.fs_close(fd)
end

-- Export ltex data depends on the type and lang especified.
M.exportFile = function(type, lang, lines)
    log.trace("Exporting ", type, lang, lines)
    local filename = M.joinPath(type, lang)
    if M.check_dir(M.path()) then
        M.writeFile(filename, lines)
    else
        log.warn("Fail export " .. filename)
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
            log.error("Failed to open file " .. filename .. ": " .. err)
            return data
        end
        uv.fs_write(fd, data)
        uv.fs_close(fd)
    end
    return data
end

-- Return the content of a required file
M.readFile = function(filename)
    log.trace("Reading ", filename)
    local fd, err = uv.fs_open(filename, "r", 420)
    if not fd then
        log.error("Failed to open file " .. filename .. ": " .. err)
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
    log.trace("Loading ", type, lang)
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
