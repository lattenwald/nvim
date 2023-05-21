return {
    {
        'folke/todo-comments.nvim',
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
        end,
    }
}
