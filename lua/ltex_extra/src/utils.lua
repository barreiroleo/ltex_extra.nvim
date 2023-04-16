local log  = require("ltex_extra.utils.log")
local path = package.loaded.ltex_extra.opts.path

local M = {}

-- Returns the filename for a type and lang required.
M.joinPath = function(type, lang)
    return vim.fs.normalize(path .. table.concat({ "ltex", type, lang, "txt" }, "."))
end

-- Check if path exist. Apply for files and dirs.
M.path_exist = function(path)
    log.trace("Checking path ", path)
    local isok, errstr, errcode = os.rename(path, path)
    if isok == nil then
        log.warn(errstr, errcode)
        return false
    end
    return true
end

-- Making a especified directory and check if created succesfully.
M.mkdir = function(dirname)
    log.trace("Making dir ", dirname)
    os.execute("mkdir " .. dirname)
    if M.path_exist(dirname) then
        log.info("Directory making succesfully ", dirname)
        return true
    else
        log.vimwarn("Fail making directory")
        return false
    end
end

-- Check if a dir exist, if not, try to making it.
M.check_dir = function(dirname)
    log.trace("Checking dir", dirname)
    if dirname == "" then return true end
    if not M.path_exist(dirname) then
        log.info(dirname .. " not found, making it")
        if M.mkdir(dirname) then return true
        else return false end
    else
        return true
    end
end

-- Write especified content into a file.
M.writeFile = function(filename, lines)
    log.trace("Writing ", filename)
    local file = io.open(filename, "a+")
    io.output(file)
    for _, line in ipairs(lines) do
        io.write(line .. "\n")
    end
    io.close(file)
end

-- Export ltex data depends on the type and lang especified.
M.exportFile = function(type, lang, lines)
    log.trace("Exporting ", type, lang, lines)
    local filename = M.joinPath(type, lang)
    if M.check_dir(path) then
        M.writeFile(filename, lines)
    else
        log.vimwarn("Fail export " .. filename)
    end
end

-- Return the content of a required file
M.readFile = function(filename)
    log.trace("Reading ", filename)
    local lines, file = {}, io.open(filename, "r")
    io.input(file)
    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end
    io.close(file)
    return lines
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
