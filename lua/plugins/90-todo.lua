return {
    {
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        config = function()
            require'todo-comments'.setup{
                keywords = {
                    XXX = {
                        icon = " ",
                        color = "error",
                    }
                },
                highlight = {
                    pattern = [[.*<(KEYWORDS)\s*]],
                },
                search = {
                    pattern = [[\b(KEYWORDS)\b]] -- ripgrep regex
                }
            }
            vim.api.nvim_set_keymap('n', '<leader>t', ':TodoTrouble<cr>', {silent = true, desc = 'Show TODOs in Trouble list'})
            vim.api.nvim_set_keymap('n', '<leader>T', ':TodoTelescope<cr>', {silent = true, desc = 'Show TODOs in Telescope picker'})
        end,
    }
}
