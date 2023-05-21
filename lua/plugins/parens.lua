return {
    {
        "windwp/nvim-autopairs",
        config = function()
            require'nvim-autopairs'.setup{}
        end
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require'nvim-surround'.setup{}
        end
    },
}
