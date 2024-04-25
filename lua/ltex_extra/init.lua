local LoggerBuilder = require("ltex_extra.utils.log")
local legacy_opts = require("ltex_extra.opts").legacy_def_opts

---LtexExtra manager.
---@class LtexExtraMgr
---@field __index LtexExtraMgr Singleton instance
---@field opts LtexExtraOpts Full options table
---@field augroup_id integer Autocommands group id
---@field ltex_client vim.lsp.Client | nil Client attached to Ltex server
---@field task_queue table{fun: fun(...), args: table{any}}
local LtexExtra = {}

---LtexExtraApi. Public endpoint to interact with LtexExtra via `require("ltex_extra")`.
---@class LtexExtraApi
---@field setup fun(opts: LtexExtraOpts | nil): boolean
---@field reload fun(...)
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

---@return vim.lsp.Client|nil client Ltex client if found
function LtexExtra:GetLtexClient()
    local ltex_client = vim.lsp.get_clients({ name = 'ltex' })[1]
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
end

--TODO: Evaluate if we need to listen the LspDetach event
function LtexExtra:ListenLtexAttach()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = LtexExtra.augroup_id,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client ~= nil and client.name == "ltex" then
                LtexExtra:SetLtexClient(client)
                LoggerBuilder.log.info(string.format("LtexExtra attached to ltex client", client.name))
            end
        end,
    })
end

---TODO: Move to commands-lsp file
---@return nil: Register client side commands
function LtexExtra:RegisterClientMethods()
    vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.commands-lsp").addToDictionary
    vim.lsp.commands["_ltex.hideFalsePositives"] = require("ltex_extra.commands-lsp").hideFalsePositives
    vim.lsp.commands["_ltex.disableRules"] = require("ltex_extra.commands-lsp").disableRules
end

---@return boolean status: True as OK, false if it's waiting for ltex attach
function LtexExtra:TriggerLoadLtexFiles()
    LtexExtra:PushTask(ltex_extra_api.reload, LtexExtra.opts.load_langs)
    return false
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
        ltex_extra_api.reload(langs)
    end, {
        nargs = "*", -- 0,1, or many
        -- selene: allow(unused_variable)
        complete = function(arglead, cmdline, cursorpos)
            return LtexExtra.opts.load_langs
        end
    })
end

function ltex_extra_api.setup(opts)
    opts = vim.tbl_deep_extend("force", legacy_opts, opts or {})
    opts.path = vim.fs.normalize(opts.path)
    LoggerBuilder:new({ logLevel = opts.log_level, usePlenary = true })

    LtexExtra:new(opts)
    -- Initialize the logger
    -- Create LtexExtra commands: Reload
    LtexExtra:RegisterAutocommands()
    -- Register client side commands
    LtexExtra:RegisterClientMethods()
    -- Load ltex files
    LtexExtra:TriggerLoadLtexFiles()
    return true
end

function ltex_extra_api.reload(...)
    require("ltex_extra.commands-lsp").reload(...)
end

function ltex_extra_api.get_opts()
    return LtexExtra.opts
end

function ltex_extra_api.get_ltex_client()
    return LtexExtra:GetLtexClient()
end

function ltex_extra_api.__debug_reset()
    require("plenary.reload").reload_module("ltex_extra")
    require("plenary.reload").reload_module("plenary.log")
end

return ltex_extra_api
