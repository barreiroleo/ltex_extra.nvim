local LoggerBuilder = require("ltex_extra.utils.log")
local legacy_opts = require("ltex_extra.opts").legacy_def_opts

---LtexExtra main class.
--@class LtexExtra
--@field new fun(opts: LtexExtraOpts): LtexExtraMgr
local LtexExtra = {}

---LtexExtra state manager. All (potentially) dynamic states should be here.
---@class LtexExtraMgr
---@field opts LtexExtraOpts
---@field augroup_id integer
---@field ltex_status boolean
local ltex_extra = nil

---LtexExtraApi. Public endpoint to interact with LtexExtra via `require("ltex_extra")`.
---@class LtexExtraApi
---@field setup fun(opts: LtexExtraOpts | nil): LtexExtraMgr
---@field reload fun(...)
---@field get_opts fun(): LtexExtraOpts
local ltex_extra_api = {}

---@param opts LtexExtraOpts
---@return LtexExtraMgr
function LtexExtra:new(opts)
    -- Singleton like
    if self.__index ~= nil then
        return self.__index
    end
    self.__index = self
    self.opts = opts
    self.augroup_id = vim.api.nvim_create_augroup("LtexExtra", { clear = false })
    return setmetatable({}, self)
end

function LtexExtra:ListenLtexAttach()
    LoggerBuilder.log.debug("Listening for ltex client attach")
    vim.api.nvim_create_autocmd("LspAttach", {
        group = LtexExtra.augroup_id,
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client ~= nil and client.name == "ltex" then
                LoggerBuilder.log.info(string.format("LtexExtra attached to ltex client", client.name, bufnr))
            end
        end,
    })
end

---@return vim.lsp.Client|nil client Ltex client if found
function LtexExtra:getLtexClient()
    -- If ltex is not up, listen to the attach event
    local ltex_client = vim.lsp.get_clients({ name = 'ltex' })[1]
    if ltex_client then
        LoggerBuilder.log.debug("ltex already running")
    else
        LtexExtra:ListenLtexAttach()
    end
    return ltex_client
end

---TODO: Move to commands-lsp file
---@return nil: Register client side commands
function LtexExtra:register_client_methods()
    vim.lsp.commands["_ltex.addToDictionary"] = require("ltex_extra.commands-lsp").addToDictionary
    vim.lsp.commands["_ltex.hideFalsePositives"] = require("ltex_extra.commands-lsp").hideFalsePositives
    vim.lsp.commands["_ltex.disableRules"] = require("ltex_extra.commands-lsp").disableRules
end

---@return boolean status: True as OK, false if it's waiting for ltex attach
function LtexExtra:trigger_load_ltex_files()
    if ltex_extra.ltex_status then
        ltex_extra_api.reload(ltex_extra.opts.load_langs)
        return true
    else
        LtexExtra:ListenLtexAttach()
        return false
    end
end

function LtexExtra:register_autocommands()
end

function ltex_extra_api.setup(opts)
    opts = vim.tbl_deep_extend("force", legacy_opts, opts or {})
    opts.path = vim.fs.normalize(opts.path)
    ltex_extra = LtexExtra:new(opts)
    -- Initialize the logger
    ---@type LoggerOpts
    ---@diagnostic disable-next-line: assign-type-mismatch
    LoggerBuilder:new({ usePlenary = true, logLevel = opts.log_level })
    -- Create LtexExtra commands: Reload
    LtexExtra:register_autocommands()
    -- Register client side commands
    LtexExtra:register_client_methods()
    -- Load ltex files
    LtexExtra:trigger_load_ltex_files()
    return ltex_extra
end

function ltex_extra_api.reload(...)
    require("ltex_extra.commands-lsp").reload(...)
end

function ltex_extra_api.get_opts()
    return ltex_extra.opts
end

function ltex_extra_api.__debug_reset()
    require("plenary.reload").reload_module("ltex_extra")
    require("plenary.reload").reload_module("plenary.log")
end

return ltex_extra_api
