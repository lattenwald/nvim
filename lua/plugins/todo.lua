return {
    {
        'folke/todo-comments.nvim',
        event = 'VeryLazy',
        opts = {
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
        },
    }
}
