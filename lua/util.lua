local util = {}

util.lsp_active = function()
    for _, client in pairs(vim.lsp.get_active_clients()) do
        if client.server_capabilities then
            return true
        end
    end
    return false
end

util.visible_buffers = function()
    return vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_list_wins())
end

util.close_floats = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            vim.api.nvim_win_close(win, false)
        end
    end
end

return util
