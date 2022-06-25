local debug = false

local inspect   = require("src.utils").inspect
local writeFile = require("src.utils").writeFile
local loadFile  = require("src.utils").readFile


local printdb = function(args)
    if debug == true then print(args) else return true end
end

local types = {
    ["dict"] = "dictionary",
    ["dRules"] = "disabledRules",
    ["hRules"] = "hiddenFalsePositives"
}

local function detect_langs()
    local buf_clients = vim.lsp.buf_get_clients()
    for _, client in ipairs(buf_clients) do
        if client.name == "ltex" then
            return client.config.settings.ltex.language
        end
    end
end

local function catch_ltex()
    local buf_clients = vim.lsp.buf_get_clients()
    local client = nil
    for _, lsp in ipairs(buf_clients) do
        if lsp.name == "ltex" then client = lsp end
    end
    return client
end

local function update_dictionary(client, lang)
    if client.config.settings.ltex.dictionary then
        client.config.settings.ltex.dictionary[lang] = loadFile(types.dict, lang)
        return client.notify('workspace/didChangeConfiguration', client.config.settings)
    else
        return vim.notify("Error when reading dictionary config, check it")
    end
end

local function update_disabledRules(client, lang)
    if client.config.settings.ltex.disabledRules then
        client.config.settings.ltex.disabledRules[lang] = loadFile(types.dRules, lang)
        return client.notify('workspace/didChangeConfiguration', client.config.settings)
    else
        return vim.notify("Error when reading disabledRules config, check it")
    end
end

local function update_hiddenFalsePositive(client, lang)
    if client.config.settings.ltex.hiddenFalsePositives then
        client.config.settings.ltex.hiddenFalsePositives[lang] = loadFile(types.hRules, lang)
        return client.notify('workspace/didChangeConfiguration', client.config.settings)
    else
        return vim.notify("Error when reading hiddenFalsePositives config, check it")
    end
end

local M = {}

M.updateConfig = function (configtype, lang)
    local client = catch_ltex()
    if client then
        if configtype == types.dict then
            update_dictionary(client, lang)
            printdb(inspect(client.config.settings.ltex.dictionary))
        elseif configtype == types.dRules then
            update_disabledRules(client, lang)
            printdb(inspect(client.config.settings.ltex.disabledRules))
        elseif configtype == types.hRules then
            update_hiddenFalsePositive(client, lang)
            printdb(inspect(client.config.settings.ltex.hiddenFalsePositives))
        end
        else
        return nil
    end
end

M.updateConfigFull = function (langs)
    vim.notify("UpdateFullConfig")
    langs = langs or {"es-AR", "en-US"}
    for _, lang in pairs(langs) do
        M.updateConfig(types.dict, lang)
        M.updateConfig(types.dRules, lang)
        M.updateConfig(types.hRules, lang)
    end
end

M.addToDictionary = function(command)
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        printdb("Lang: " .. inspect(lang) .. "\n" .. "Words: " .. inspect(words))
        writeFile(types.dict, lang, words)
        M.updateConfig(types.dict, lang)
    end
end

M.disableRules = function(command)
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        printdb("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile(types.dRules, lang, rules)
        M.updateConfig(types.dRules, lang)
    end
end

M.hideFalsePositives = function(command)
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        printdb("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile(types.hRules, lang, rules)
        M.updateConfig(types.hRules, lang)
    end
end

local orig_execute_command = vim.lsp.buf.execute_command
vim.lsp.buf.execute_command = function(command)
    -- printdb(vim.inspect(command))
    if command.command == '_ltex.addToDictionary' then
        M.addToDictionary(command)
    elseif command.command == '_ltex.disableRules' then
        M.disableRules(command)
    elseif command.command == '_ltex.hideFalsePositives' then
        M.hideFalsePositives(command)
    else
        orig_execute_command(command)
    end
end

return M
