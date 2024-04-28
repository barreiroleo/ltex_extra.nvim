local LoggerBuilder = require("ltex_extra.utils.log")
local legacy_opts = require("ltex_extra.opts").legacy_def_opts

---@alias LtexClientSettings {ltex: {dictionary: content, hiddenFalsePositives: content, disabledRules: content }}
---@alias content {[string]: string[]}

---LtexExtra manager.
---@class LtexExtraMgr
---@field __index LtexExtraMgr Singleton instance
---@field opts LtexExtraOpts Full options table
---@field augroup_id integer Autocommands group id
---@field ltex_client vim.lsp.Client|nil Client attached to Ltex server
---@field internal_settings LtexClientSettings Internal representation of custom settings.
local LtexExtra = {}

---LtexExtraApi. Public endpoint to interact with LtexExtra via `require("ltex_extra")`.
---@class LtexExtraApi
---@field setup fun(opts: LtexExtraOpts|nil): boolean
---@field reload fun(...)
---@field check_document fun()
---@field get_server_status fun(): { err: lsp.ResponseError|nil, result: any }|nil
---@field __get_opts fun(): LtexExtraOpts
local ltex_extra_api = {}

---@param opts LtexExtraOpts
---@return LtexExtraMgr
function LtexExtra:new(opts)
    if not self.__index then
        self.__index = self
        self.opts = opts
        self.augroup_id = vim.api.nvim_create_augroup("LtexExtra", { clear = false })
        self.ltex_client = self:GetLtexClient()
        self.internal_settings = {}
    end
    return self
end

---TODO: Remove get_active_clients when 0.10 is released
---@return vim.lsp.Client|nil client Ltex client if found
function LtexExtra:GetLtexClient()
    local ltex_client = nil
    if vim.lsp.get_clients then
        ltex_client = vim.lsp.get_clients({ name = 'ltex' })[1]
    else
        ltex_client = vim.lsp.get_active_clients({ name = 'ltex' })[1]
    end

    if not ltex_client then
        LoggerBuilder.log.info("Ltex client not found. Waiting for attach")
        LtexExtra:ListenLtexAttach()
    end
    return ltex_client
end

---@param client vim.lsp.Client
function LtexExtra:SetLtexClient(client)
    LtexExtra.ltex_client = client
    local disk_settings = LtexExtra:GetSettingsFromFile()
    LtexExtra:SetLtexSettings(disk_settings)
end

---@param settings LtexClientSettings
function LtexExtra:SetLtexSettings(settings)
    local client = LtexExtra:GetLtexClient()
    assert(client, "Client not available")
    LtexExtra.internal_settings = vim.tbl_deep_extend("force", client.settings, settings)
    LtexExtra:SyncInternalState()
end

function LtexExtra:GetLtexSettings()
    return LtexExtra.internal_settings
end

function LtexExtra:SyncInternalState()
    local client = LtexExtra:GetLtexClient()
    assert(client ~= nil, "Error to sync setings. Client not available")
    client.settings.ltex = LtexExtra:GetLtexSettings().ltex
    return client.notify("workspace/didChangeConfiguration", LtexExtra:GetLtexSettings())
end

---@param langs? language[]
---@return LtexClientSettings
function LtexExtra:GetSettingsFromFile(langs)
    local fs_loadFile = require("ltex_extra.utils.fs").loadFile
    ---@type LtexClientSettings
    local settings = { ltex = { dictionary = {}, disabledRules = {}, hiddenFalsePositives = {} } }
    for _, lang in pairs(langs or LtexExtra.opts.load_langs) do
        settings.ltex.dictionary[lang] = fs_loadFile("dictionary", lang)
        settings.ltex.disabledRules[lang] = fs_loadFile("disabledRules", lang)
        settings.ltex.hiddenFalsePositives[lang] = fs_loadFile("hiddenFalsePositives", lang)
    end
    return settings
end

function LtexExtra:ListenLtexAttach()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = LtexExtra.augroup_id,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client ~= nil and client.name == "ltex" then
                vim.defer_fn(function() LtexExtra:SetLtexClient(client) end, 1000)
                LoggerBuilder.log.info(string.format("Client %d attached to ltex server", client.id))
            end
        end,
    })
end

function LtexExtra:RegisterAutocommands()
    vim.api.nvim_create_user_command("LtexExtraReload", function(opts)
        -- local fargs = { '"es-AR"', '"en-US"' }
        local langs = {}
        for _, lang in ipairs(opts.fargs) do
            for k in string.gmatch(lang, "(%w*-%w*)") do table.insert(langs, k) end
        end
        if vim.tbl_isempty(langs) then
            langs = LtexExtra.opts.load_langs
        end
        ltex_extra_api.reload(langs)
    end, {
        nargs = "*",
        complete = function()
            return LtexExtra.opts.load_langs
        end
    })
end

---@return nil: Register client side commands
function LtexExtra:RegisterClientMethods()
    vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.commands-lsp").addToDictionary
    vim.lsp.commands["_ltex.hideFalsePositives"] = require("ltex_extra.commands-lsp").hideFalsePositives
    vim.lsp.commands["_ltex.disableRules"] = require("ltex_extra.commands-lsp").disableRules
end

---@param opts Legacy_LtexExtraOpts
function LtexExtra:CheckLegacyOpts(opts)
    local deprecated_in_use = {}
    if opts.server_start then
        table.insert(deprecated_in_use, "server_start")
    end
    if opts.server_opts then
        table.insert(deprecated_in_use, "server_opts")
    end
    for _, opt in pairs(deprecated_in_use) do
        vim.notify(string.format("[LtexExtra] %s will be deprecatd soon. Please consider updating your settings." ..
            " Raise an issue at github.com/barreiroleo/ltex_extra.nvim if you have any concerns.", opt),
            vim.log.levels.WARN)
    end
end

---@deprecated
---@param opts LSPServerOpts
function LtexExtra:CallLtexServer(opts)
    local ok, lspconfig = pcall(require, "lspconfig")
    if not ok then
        error("[LtexExtra] Cannot initialize ltex server. Lspconfig not found")
    end
    lspconfig["ltex"].setup(opts)
end

function ltex_extra_api.setup(opts)
    opts = vim.tbl_deep_extend("force", legacy_opts, opts or {})
    opts.path = vim.fs.normalize(opts.path)
    -- Initialize the logger
    LoggerBuilder:new({ logLevel = opts.log_level, usePlenary = true })
    LtexExtra:new(opts)
    LtexExtra:RegisterAutocommands()
    LtexExtra:RegisterClientMethods()
    -- Legacy support for server start. Deprecated soon.
    if opts.server_start and opts.server_opts then
        LtexExtra:CallLtexServer(opts.server_opts)
    end
    vim.schedule(function() LtexExtra:CheckLegacyOpts(opts) end)
    return true
end

---@param langs? language[]
function ltex_extra_api.reload(langs)
    local settings = LtexExtra:GetSettingsFromFile(langs)
    LtexExtra:SetLtexSettings(settings)
end

---@return { err: lsp.ResponseError|nil, result: any }|nil
function ltex_extra_api.check_document()
    local client = LtexExtra:GetLtexClient()
    assert(client, "Cannot request document check. Client not available.")
    local bufnr = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_text_document_params(bufnr)
    local method, command = "workspace/executeCommand", "_ltex.checkDocument"
    return client.request_sync(method, { command = command, arguments = params }, nil, bufnr)
end

function ltex_extra_api.get_server_status()
    local client = LtexExtra:GetLtexClient()
    assert(client, "Error to get the server status. Client not available")
    local bufnr = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_text_document_params(bufnr)
    local method, command = "workspace/executeCommand", "_ltex.getServerStatus"
    return client.request_sync(method, { command = command, arguments = params }, nil, bufnr)
end

---@param type "dictionary"| "disabledRules"| "hiddenFalsePositives",
---@param lang language
---@param content string[]
function ltex_extra_api.push_setting(type, lang, content)
    local settings = vim.tbl_deep_extend("keep", LtexExtra:GetLtexSettings(), {
        ltex = { [type] = { [lang] = {} } }
    })
    vim.list_extend(settings.ltex[type][lang], content)
    LtexExtra:SetLtexSettings(settings)
end

function ltex_extra_api.__get_opts()
    return LtexExtra.opts
end

function ltex_extra_api.__debug_reset()
    require("plenary.reload").reload_module("ltex_extra")
    require("plenary.reload").reload_module("plenary.log")
end

return ltex_extra_api
