local log = require("ltex_extra.src.log")

local exportFile = require("ltex_extra.src.utils").exportFile
local loadFile  = require("ltex_extra.src.utils").loadFile

local types = {
    ["dict"] = "dictionary",
    ["dRules"] = "disabledRules",
    ["hRules"] = "hiddenFalsePositives"
}

local function catch_ltex()
    log.trace("catch_ltex")
    local buf_clients = vim.lsp.buf_get_clients()
    local client = nil
    for _, lsp in pairs(buf_clients) do
        if lsp.name == "ltex" then client = lsp end
    end
    return client
end

local function update_dictionary(client, lang)
    log.trace("update_dictionary")
    if not client.config.settings.ltex.dictionary then
        client.config.settings.ltex.dictionary = {}
    end
    client.config.settings.ltex.dictionary[lang] = loadFile(types.dict, lang)
    log.debug(vim.inspect(client.config.settings.ltex.dictionary))
    return client.notify('workspace/didChangeConfiguration', client.config.settings)
end

local function update_disabledRules(client, lang)
    log.trace("update_disabledRules")
    if not client.config.settings.ltex.disabledRules then
        client.config.settings.ltex.disabledRules = {}
    end
    client.config.settings.ltex.disabledRules[lang] = loadFile(types.dRules, lang)
    log.debug(vim.inspect(client.config.settings.ltex.disabledRules))
    return client.notify('workspace/didChangeConfiguration', client.config.settings)
end

local function update_hiddenFalsePositive(client, lang)
    log.trace("update_hiddenFalsePositive")
    if not client.config.settings.ltex.hiddenFalsePositives then
        client.config.settings.ltex.hiddenFalsePositives = {}
    end
    client.config.settings.ltex.hiddenFalsePositives[lang] = loadFile(types.hRules, lang)
    log.debug(vim.inspect(client.config.settings.ltex.hiddenFalsePositives))
    return client.notify('workspace/didChangeConfiguration', client.config.settings)
end

local M = {}

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
        else
            log.fmt_error("Config type unknown")
            return vim.notify("Config type unknown")
        end
    else
        log.fmt_error("Error catching ltex client")
        return vim.notify("Error catching ltex client")
    end
end

M.reload = function(langs)
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
        log.fmt_debug("Lang: %s Words: %s", vim.inspect(lang), vim.inspect(words))
        exportFile(types.dict, lang, words)
        M.updateConfig(types.dict, lang)
    end
end

M.disableRules = function(command)
    log.trace("disableRules")
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        log.fmt_debug("Lang: %s Rules: %s", vim.inspect(lang), vim.inspect(rules))
        exportFile(types.dRules, lang, rules)
        M.updateConfig(types.dRules, lang)
    end
end

M.hideFalsePositives = function(command)
    log.trace("hideFalsePositives")
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        log.fmt_debug("Lang: %s Rules: %s", vim.inspect(lang), vim.inspect(rules))
        exportFile(types.hRules, lang, rules)
        M.updateConfig(types.hRules, lang)
    end
end

return M
