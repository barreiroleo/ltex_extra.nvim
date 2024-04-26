-- The official vsco** extension does more or less the following:
-- At client start, sets the special capability:
--      ltex/workspaceSpecificationConfiguration` and binds a handler as callback.
-- After executing a client command calls in order the `addToLanguageSpecificSetting` & `checkCurrentDocument`
-- `addToLanguageSpecificSetting` (uri, action, args) => (uri, 'dictionary', params.words)
--      This adds the langs settings to an external file or an interal settings, depends on the config.
--      The external export, adds the settings to the internal settings at the ends anyways.
--      The interal save, calls a clean up for the workspace.
-- `checkCurrentDocument` (): Calls checkDocument(uri, languageId, text): This method send a request as follows:
--      sendRequest(method:"workspace/executeCommand",command:"_ltex.checkDocument", arguments: uri)


local log = require("ltex_extra.utils.log").log
local ltex_extra_api = require("ltex_extra")

local exportFile = require("ltex_extra.utils.fs").exportFile
local loadFile = require("ltex_extra.utils.fs").loadFile

local types = {
    ["dict"] = "dictionary",
    ["dRules"] = "disabledRules",
    ["hRules"] = "hiddenFalsePositives",
}

---@param client vim.lsp.Client
local function get_settings(client)
    if not client.config.settings.ltex then
        client.config.settings.ltex = {}
    end
    for _, index in pairs(types) do
        if not client.config.settings.ltex[index] then
            client.config.settings.ltex[index] = {}
        end
    end
    return client.config.settings
end

---@param client vim.lsp.Client
---@param lang language
local function update_dictionary(client, lang)
    log.trace("update_dictionary")
    local settings = get_settings(client)
    settings.ltex.dictionary[lang] = loadFile(types.dict, lang)
    log.debug(vim.inspect(settings.ltex.dictionary))
    return client.notify("workspace/didChangeConfiguration", settings)
end

---@param client vim.lsp.Client
---@param lang language
local function update_disabledRules(client, lang)
    log.trace("update_disabledRules")
    local settings = get_settings(client)
    settings.ltex.disabledRules[lang] = loadFile(types.dRules, lang)
    log.debug(vim.inspect(settings.ltex.disabledRules))
    return client.notify("workspace/didChangeConfiguration", settings)
end

---@param client vim.lsp.Client
---@param lang language
local function update_hiddenFalsePositive(client, lang)
    log.trace("update_hiddenFalsePositive")
    local settings = get_settings(client)
    settings.ltex.hiddenFalsePositives[lang] = loadFile(types.hRules, lang)
    log.debug(vim.inspect(settings.ltex.hiddenFalsePositives))
    return client.notify("workspace/didChangeConfiguration", settings)
end

local M = {}

function M.updateConfig(configtype, lang)
    log.trace("updateConfig")
    local client = ltex_extra_api.__get_ltex_client()
    if client then
        if configtype == types.dict then
            update_dictionary(client, lang)
        elseif configtype == types.dRules then
            update_disabledRules(client, lang)
        elseif configtype == types.hRules then
            update_hiddenFalsePositive(client, lang)
        else
            return log.error("Unknown config type")
        end
    else
        return error("Error catching ltex client", 1)
    end
end

---@param langs language[]
function M.reload(langs)
    log.trace("updateConfigFull")
    langs = langs or ltex_extra_api.__get_opts().load_langs
    for _, lang in pairs(langs) do
        lang = string.lower(lang)
        log.trace(string.format("Loading %s", lang))
        vim.schedule(function()
            M.updateConfig(types.dict, lang)
            M.updateConfig(types.dRules, lang)
            M.updateConfig(types.hRules, lang)
        end)
    end
end

---@param command  AddToDictionaryCommandParams
function M.addToDictionary(command)
    log.trace("addToDictionary")
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        log.debug(string.format("Lang: %s Words: %s", vim.inspect(lang), vim.inspect(words)))
        exportFile(types.dict, lang, words)
        vim.schedule(function()
            M.updateConfig(types.dict, lang)
        end)
    end
end

---@param command DisableRulesCommandParams
function M.disableRules(command)
    log.trace("disableRules")
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        log.debug(string.format("Lang: %s Rules: %s", vim.inspect(lang), vim.inspect(rules)))
        exportFile(types.dRules, lang, rules)
        vim.schedule(function()
            M.updateConfig(types.dRules, lang)
        end)
    end
end

---@param command HideFalsePositivesCommandParams
function M.hideFalsePositives(command)
    log.trace("hideFalsePositives")
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        log.debug(string.format("Lang: %s Rules: %s", vim.inspect(lang), vim.inspect(rules)))
        exportFile(types.hRules, lang, rules)
        vim.schedule(function()
            M.updateConfig(types.hRules, lang)
        end)
    end
end

return M
