local get_code_actions = require("test.utils.init").get_code_actions
local load_file = require("test.utils.init").load_file
local spawn_window = require("test.utils.init").spawn_window


local test_filename = vim.fs.normalize("./test/assets/main.md")

local test_bufnr = load_file(test_filename)
assert(test_bufnr ~= nil, "Faied to load test file")

local win = spawn_window(test_bufnr)


local ltex_client = vim.lsp.get_clients({ bufnr = test_bufnr, name = "ltex" })[1]
local params = vim.lsp.util.make_range_params(win)
params["context"] = {
    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(test_bufnr, nil, nil, ltex_client.id)
}

vim.api.nvim_win_set_cursor(win, { 9, 10 })
local ltex_code_actions = get_code_actions(ltex_client.id, params, test_bufnr)

P(ltex_code_actions)
