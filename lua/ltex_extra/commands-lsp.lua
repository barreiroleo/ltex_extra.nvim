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

local types = {
    ["dict"] = "dictionary",
    ["dRules"] = "disabledRules",
    ["hRules"] = "hiddenFalsePositives",
}

---@param client vim.lsp.Client
local function update_settings(client)
    log.trace("update_dictionary")
    local settings = ltex_extra_api.get_ltex_client().settings
    settings.ltex = ltex_extra_api.get_internal_settings().ltex
    return client.notify("workspace/didChangeConfiguration", ltex_extra_api.get_internal_settings())
end

local M = {}

function M.updateConfig()
    log.trace("updateConfig")
    local client = ltex_extra_api.get_ltex_client()
    if client then
        update_settings(client)
    else
        return error("Error catching ltex client", 1)
    end
end

---@param langs language[]
function M.reload(langs)
    log.trace("updateConfigFull")
    langs = langs or ltex_extra_api.get_opts().load_langs
    for _, lang in pairs(langs) do
        log.trace(string.format("Loading %s", lang))
        vim.schedule(function()
            M.updateConfig()
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
            ltex_extra_api.push_setting(types.dict, lang, words)
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
            ltex_extra_api.push_setting(types.dRules, lang, rules)
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
            ltex_extra_api.push_setting(types.hRules, lang, rules)
        end)
    end
end

return M
