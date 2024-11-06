return {
    {
        'folke/todo-comments.nvim',
        config = function()
            require'todo-comments'.setup{
                keywords = {
                    XXX = {
                        icon = " ",
                        color = "error",
                    },
                    TODO = {
                        icon = " ",
                        color = "info",
                        alt = { "todo" },
                    },
                },
                highlight = {
                    pattern = [[.*<(KEYWORDS)\s*]],
                },
                search = {
                    pattern = [[\b(KEYWORDS)\b]] -- ripgrep regex
                }
            }
            vim.keymap.set('n', '<leader>t', '<cmd>TodoTrouble<cr>', {silent = true, desc = 'Show TODOs in Trouble list'})
            vim.keymap.set('n', '<leader>T', '<cmd>TodoTelescope<cr>', {silent = true, desc = 'Show TODOs in Telescope picker'})
        end,
    }
}
