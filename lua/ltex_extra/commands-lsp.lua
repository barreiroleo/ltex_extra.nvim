local log = require("ltex_extra.utils.log")

local exportFile = require("ltex_extra.utils.fs").exportFile
local loadFile = require("ltex_extra.utils.fs").loadFile

local types = {
    ["dict"] = "dictionary",
    ["dRules"] = "disabledRules",
    ["hRules"] = "hiddenFalsePositives",
}

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

local function update_dictionary(client, lang)
    log.trace("update_dictionary")
    local settings = get_settings(client)
    settings.ltex.dictionary[lang] = loadFile(types.dict, lang)
    log.debug(vim.inspect(settings.ltex.dictionary))
    return client.notify("workspace/didChangeConfiguration", settings)
end

local function update_disabledRules(client, lang)
    log.trace("update_disabledRules")
    local settings = get_settings(client)
    settings.ltex.disabledRules[lang] = loadFile(types.dRules, lang)
    log.debug(vim.inspect(settings.ltex.disabledRules))
    return client.notify("workspace/didChangeConfiguration", settings)
end

local function update_hiddenFalsePositive(client, lang)
    log.trace("update_hiddenFalsePositive")
    local settings = get_settings(client)
    settings.ltex.hiddenFalsePositives[lang] = loadFile(types.hRules, lang)
    log.debug(vim.inspect(settings.ltex.hiddenFalsePositives))
    return client.notify("workspace/didChangeConfiguration", settings)
end

local M = {}

function M.catch_ltex()
    log.trace("catch_ltex")
    local client_getter = vim.lsp.get_clients and vim.lsp.get_clients or vim.lsp.get_active_clients

    local ok, buf_clients = pcall(client_getter, {
        bufnr = vim.api.nvim_get_current_buf(),
        name = "ltex",
    })

    if not ok then
        buf_clients = client_getter({
            bufnr = vim.api.nvim_get_current_buf(),
            name = "ltex_plus",
        })
    end

    return buf_clients[1]
end

function M.updateConfig(configtype, lang)
    log.trace("updateConfig")
    local client = M.catch_ltex()
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
        return error("Error catching ltex client", 1)
    end
end

function M.reload(langs)
    log.trace("updateConfigFull")
    langs = langs or package.loaded.ltex_extra.opts.load_langs
    for _, lang in pairs(langs) do
        log.fmt_trace("Loading %s", lang)
        vim.schedule(function()
            M.updateConfig(types.dict, lang)
            M.updateConfig(types.dRules, lang)
            M.updateConfig(types.hRules, lang)
        end)
    end
end

function M.addToDictionary(command)
    log.trace("addToDictionary")
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        log.fmt_debug("Lang: %s Words: %s", vim.inspect(lang), vim.inspect(words))
        exportFile(types.dict, lang, words)
        vim.schedule(function()
            M.updateConfig(types.dict, lang)
        end)
    end
end

function M.disableRules(command)
    log.trace("disableRules")
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        log.fmt_debug("Lang: %s Rules: %s", vim.inspect(lang), vim.inspect(rules))
        exportFile(types.dRules, lang, rules)
        vim.schedule(function()
            M.updateConfig(types.dRules, lang)
        end)
    end
end

function M.hideFalsePositives(command)
    log.trace("hideFalsePositives")
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        log.fmt_debug("Lang: %s Rules: %s", vim.inspect(lang), vim.inspect(rules))
        exportFile(types.hRules, lang, rules)
        vim.schedule(function()
            M.updateConfig(types.hRules, lang)
        end)
    end
end

return M
