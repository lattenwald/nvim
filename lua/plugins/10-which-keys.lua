return {
    {
        "folke/which-key.nvim",
        dependencies = {
            'echasnovski/mini.icons',
        },
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },
}
