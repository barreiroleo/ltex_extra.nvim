local load_file = require("test.utils.init").load_file
local spawn_window = require("test.utils.init").spawn_window


---@type string
local test_filename = vim.fs.normalize("./test/assets/main.md")


---@alias TestCase {[string]:{row: integer, col: integer}}
---@type TestCase[]
local test_cases = {
    addToDictionary = { 9, 10 },
    hideFalsePositive = { 13, 0 },
    disableRule = { 17, 9 }
}


-- Load test assset.
local test_bufnr = load_file(test_filename)
assert(test_bufnr ~= nil, string.format("Error loading %s in new buffer", test_filename))
local test_winid = spawn_window(test_bufnr)

-- Go to position.
vim.api.nvim_win_set_cursor(test_winid, test_cases.disableRule)

-- Execute command.
---@type vim.lsp.buf.code_action.Opts
local code_action_opts = {
    filter = function(action)
        return action.kind == "quickfix.ltex.disableRules"
    end,
    apply = true,
}
vim.lsp.buf.code_action(code_action_opts)


-- Code action passed to the code action filter
--
-- {
--   command = {
--     arguments = { {
--         ruleIds = {
--           ["en-us"] = { "EN_UNPAIRED_BRACKETS" }
--         },
--         uri = "file:///home/leonardo/develop/ltex_extra.nvim/test/assets/main.md"
--       } },
--     command = "_ltex.disableRules",
--     title = "Disable rule"
--   },
--   diagnostics = { {
--       code = "EN_UNPAIRED_BRACKETS",
--       codeDescription = {
--         href = "https://community.languagetool.org/rule/show/EN_UNPAIRED_BRACKETS?lang=en-us"
--       },
--       message = "Unpaired symbol: ''' seems to be missing",
--       range = {
--         ["end"] = {
--           character = 10,
--           line = 16
--         },
--         start = {
--           character = 9,
--           line = 16
--         }
--       },
--       severity = 3,
--       source = "LTeX"
--     } },
--   kind = "quickfix.ltex.disableRules",
--   title = "Disable rule"
-- }
