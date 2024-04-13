vim.opt.runtimepath:append(".")

vim.o.swapfile = false
vim.bo.swapfile = false

function reset_editor()
    vim.notify("Reset editor", vim.log.levels.WARN)
    vim.cmd.tabonly({ mods = { silent = true } })
    for i, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if i > 1 then
            vim.api.nvim_win_close(winid, true)
        end
    end
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

reset_editor()
