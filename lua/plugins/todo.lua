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
                }
            }
        end,
    }
}
