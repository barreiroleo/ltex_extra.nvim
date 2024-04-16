local M = {}

---Loads the specified file into a new buffer and returns the buffer's id
---@param filepath string: Resolved file path. Preferible normalized
---@return integer | nil: Buffer where the file is load. nil on error
function M.load_file(filepath)
    local bufnr = nil
    -- Cache current buffer and restore it after load the test asset
    local current_bufnr = vim.api.nvim_get_current_buf()
    vim.cmd.edit({ args = { filepath } })
    local new_bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(0, current_bufnr)
    -- Check we are looking at correct buffer
    if string.match(vim.api.nvim_buf_get_name(new_bufnr), filepath) then
        bufnr = new_bufnr
        vim.notify("File loaded successfull")
    end
    assert(bufnr ~= nil, string.format("Error loading %s in new buffer", filepath))
    return bufnr
end

---Spawn a floating windows where to load the specified buffer
---@param bufnr integer: Buffer identifier
---@return integer: Window identifier. Returns O on error
function M.spawn_window(bufnr)
    ---@format disable-next
    local winnr = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",                                       --
        width = 100, height = 20, row = 1, col = 1,                --
        style = "minimal", border = "rounded",                     --
        title = "main.md", title_pos = "center", noautocmd = true, --
    })
    assert(winnr ~= 0, "Error spawining window for buffer " .. bufnr)
    return winnr
end

---Request the code actions to the servers attached to a specific buffer for a specific location/range.
---Then filters the result map and returns only the matches for the ltex client.
---@param ltex_client_id integer: Client listener of Ltex
---@param params any: LSP params resolved. Indicates the location and rage.
---@param bufnr integer: Buffer id where the code actions are obtained.
---@return table|nil: Table with code actions
function M.get_code_actions(ltex_client_id, params, bufnr)
    ---@type table<integer, { err: lsp.ResponseError, result: any }>
    local result_map, err = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params)
    if err then
        assert(err == nil, "Error retrieving code actions for cursor position: " .. err)
        return nil
    end

    for client_id, response in pairs(result_map) do
        if client_id == ltex_client_id then
            return response.result
        end
    end
end

return M
