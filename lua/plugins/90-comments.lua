return {
    {
        "terrortylor/nvim-comment",
        config = function()
            require'nvim_comment'.setup({
                    create_mappings = false,
                })
            vim.api.nvim_set_keymap('n', '<leader>c<space>', ':CommentToggle<cr>', {desc = "Toggle comment"})
            vim.api.nvim_set_keymap('v', '<leader>c<space>', ':CommentToggle<cr>', {desc = "Toggle comment"})
        end,
    }
}
