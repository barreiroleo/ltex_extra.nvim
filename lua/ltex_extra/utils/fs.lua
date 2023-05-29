local log = require("ltex_extra.utils.log")
local config_path = package.loaded.ltex_extra.opts.path

local M = {}

-- Returns path to the directory where ltex files should be located.
M.path = function()
    -- Check if the absolute path the user has provided is valid
    if config_path ~= "" and M.path_exist(config_path) then
        return config_path .. "/"
    else
        -- Assume relative path so append to the cwd
        return vim.fs.normalize(vim.loop.cwd() .. "/" .. config_path) .. "/"
    end
end

-- Returns the filename for a type and lang required.
M.joinPath = function(type, lang)
    return vim.fs.normalize(M.path() .. table.concat({ "ltex", type, lang, "txt" }, "."))
end

-- Check if path exist. Apply for files and dirs.
M.path_exist = function(path)
    log.trace("Checking path ", path)
    return vim.loop.fs_stat(path) ~= nil
end

-- Make a specified directory and check if created succesfully.
M.mkdir = function(dirname)
    log.trace("Making dir ", dirname)
    local perm = tonumber("744", 8)
    local ok, err = vim.loop.fs_mkdir(dirname, perm)
    if not ok then
        log.vimwarn("Failed making directory: ", err)
        return false
    else
        log.info("Directory made succesfully ", dirname)
        return true
    end
end

-- Check if a dir exist, if not, try to making it.
M.check_dir = function(dirname)
    log.trace("Checking dir", dirname)
    local stat = vim.loop.fs_stat(dirname)
    if not stat then
        log.info(dirname .. " not found, making it")
        if M.mkdir(dirname) then
            return true
        end
    end
    ---@diagnostic disable-next-line: need-check-nil
    if stat.type ~= "directory" then
        log.vimwarn(dirname .. " is not a directory")
        return false
    end
    return true
end

-- Write specified content into a file.
M.writeFile = function(filename, lines)
    log.trace("Writing ", filename, lines)
    local fd, err = vim.loop.fs_open(filename, "a+", 420)
    if not fd then
        log.vimerror("Failed to open file " .. filename .. ": " .. err)
        return
    end
    vim.loop.fs_write(fd, table.concat(lines, "\n") .. "\n")
    vim.loop.fs_close(fd)
end

-- Export ltex data depends on the type and lang especified.
M.exportFile = function(type, lang, lines)
    log.trace("Exporting ", type, lang, lines)
    local filename = M.joinPath(type, lang)
    if M.check_dir(M.path()) then
        M.writeFile(filename, lines)
    else
        log.vimwarn("Fail export " .. filename)
    end
end

-- Return the content of a required file
M.readFile = function(filename)
    log.trace("Reading ", filename)
    local fd, err = vim.loop.fs_open(filename, "r", 420)
    if not fd then
        log.vimerror("Failed to open file " .. filename .. ": " .. err)
        return {}
    end
    local stat = vim.loop.fs_fstat(fd)
    if not stat then
        return {}
    end
    local data = vim.loop.fs_read(fd, stat.size)
    vim.loop.fs_close(fd)
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
