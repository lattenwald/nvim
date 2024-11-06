return {
    {
        "terrortylor/nvim-comment",
        enabled = false,
        config = function()
            require'nvim_comment'.setup({
                    create_mappings = false,
                })
            vim.keymap.set({'n', 'v'}, '<leader>c<space>', ':CommentToggle<cr>', {desc = "Toggle comment"})
        end,
    },
    {
        'echasnovski/mini.comment',
        opts = {
            options = {
                ignore_blank_line = true,
            },
            mappings = {
                comment = '<leader>cc',
                comment_line = '<leader>c<space>',
                comment_visual = '<leader>c<space>',
                textobject = '<leader>cc',
            }
        }
    },
}
