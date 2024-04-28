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
---@field task_queue {fun: fun(...), args: any} Task queue for pending task
---@field internal_settings LtexClientSettings Internal representation of custom settings.
local LtexExtra = {}

---LtexExtraApi. Public endpoint to interact with LtexExtra via `require("ltex_extra")`.
---@class LtexExtraApi
---@field setup fun(opts: LtexExtraOpts|nil): boolean
---@field reload fun(...)
---@field check_document fun()
---@field get_server_status fun(): { err: lsp.ResponseError|nil, result: any }|nil
---@field get_opts fun(): LtexExtraOpts
local ltex_extra_api = {}

---@param opts LtexExtraOpts
---@return LtexExtraMgr
function LtexExtra:new(opts)
    if not self.__index then
        self.__index = self
        self.opts = opts
        self.augroup_id = vim.api.nvim_create_augroup("LtexExtra", { clear = false })
        self.ltex_client = self:GetLtexClient()
        self.task_queue = {}
        self.internal_settings = {}
    end
    return self
end

---@param callback fun(...)
---@param args table{any}
function LtexExtra:PushTask(callback, args)
    if LtexExtra.ltex_client then
        callback(args)
    else
        LoggerBuilder.log.trace("Client not running. Queuing the task.")
        table.insert(LtexExtra.task_queue, { fun = callback, args = args })
    end
end

function LtexExtra:ResolvePendingTasks()
    for _, task in pairs(LtexExtra.task_queue) do
        LoggerBuilder.log.trace(task)
        task.fun(task.args)
    end
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

    if ltex_client then
        LoggerBuilder.log.debug("Ltex client found at client id " .. ltex_client.id)
    else
        LoggerBuilder.log.info("Ltex client not found. Waiting for attach")
        LtexExtra:ListenLtexAttach()
    end
    return ltex_client
end

---@param client vim.lsp.Client
function LtexExtra:SetLtexClient(client)
    LtexExtra.ltex_client = client
    LtexExtra:ResolvePendingTasks()
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

--return LtexClientSettings
function LtexExtra:GetSettingsFromFile()
    local fs_loadFile = require("ltex_extra.utils.fs").loadFile
    ---@type LtexClientSettings
    local settings = { ltex = { dictionary = {}, disabledRules = {}, hiddenFalsePositives = {} } }
    for _, lang in pairs(LtexExtra.opts.load_langs) do
        settings.ltex.dictionary[lang] = fs_loadFile("dictionary", lang)
        settings.ltex.disabledRules[lang] = fs_loadFile("disabledRules", lang)
        settings.ltex.hiddenFalsePositives[lang] = fs_loadFile("hiddenFalsePositives", lang)
    end
    return settings
end

--TODO: Evaluate if we need to listen the LspDetach event
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
        LoggerBuilder.log.info(string.format("LtexExtraReload: Reloading %s ", vim.inspect(langs)))
        ltex_extra_api.reload()
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

function ltex_extra_api.setup(opts)
    opts = vim.tbl_deep_extend("force", legacy_opts, opts or {})
    opts.path = vim.fs.normalize(opts.path)
    -- Initialize the logger
    LoggerBuilder:new({ logLevel = opts.log_level, usePlenary = true })
    LtexExtra:new(opts)
    -- Create LtexExtra commands
    LtexExtra:RegisterAutocommands()
    -- Register client side commands
    LtexExtra:RegisterClientMethods()
    return true
end

function ltex_extra_api.reload()
    assert(nil, "Pending implementation")
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

function ltex_extra_api.get_opts()
    return LtexExtra.opts
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

function ltex_extra_api.__debug_reset()
    require("plenary.reload").reload_module("ltex_extra")
    require("plenary.reload").reload_module("plenary.log")
end

vim.api.nvim_create_user_command("LtexExtraTest", function() end, {})

return ltex_extra_api
