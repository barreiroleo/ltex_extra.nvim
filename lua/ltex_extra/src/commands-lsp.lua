local log = require("ltex_extra.src.log")

local inspect   = require("ltex_extra.src.utils").inspect
local writeFile = require("ltex_extra.src.utils").writeFile
local loadFile  = require("ltex_extra.src.utils").readFile

local types = {
    ["dict"] = "dictionary",
    ["dRules"] = "disabledRules",
    ["hRules"] = "hiddenFalsePositives"
}

local function catch_ltex()
    log.trace("catch_ltex")
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
M.updateConfig = function(configtype, lang)
    log.trace("updateConfig")
    local client = catch_ltex()
    if client then
        if configtype == types.dict then
            update_dictionary(client, lang)
        elseif configtype == types.dRules then
            update_disabledRules(client, lang)
        elseif configtype == types.hRules then
            update_hiddenFalsePositive(client, lang)
        end
        else
        return nil
    end
end

M.updateConfigFull = function(langs)
    log.trace("updateConfigFull")
    langs = langs or package.loaded.ltex_extra.opts.load_langs
    for _, lang in pairs(langs) do
        log.fmt_trace("Loading %s", lang)
        M.updateConfig(types.dict, lang)
        M.updateConfig(types.dRules, lang)
        M.updateConfig(types.hRules, lang)
    end
end

M.addToDictionary = function(command)
    log.trace("addToDictionary")
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        log.fmt_debug("Lang: %s Words: %s", inspect(lang), inspect(words))
        writeFile(types.dict, lang, words)
        M.updateConfig(types.dict, lang)
    end
end

M.disableRules = function(command)
    log.trace("disableRules")
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        log.fmt_debug("Lang: %s Rules: %s", inspect(lang), inspect(rules))
        writeFile(types.dRules, lang, rules)
        M.updateConfig(types.dRules, lang)
    end
end

M.hideFalsePositives = function(command)
    log.trace("hideFalsePositives")
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        log.fmt_debug("Lang: %s Rules: %s", inspect(lang), inspect(rules))
        writeFile(types.hRules, lang, rules)
        M.updateConfig(types.hRules, lang)
    end
end

return M
