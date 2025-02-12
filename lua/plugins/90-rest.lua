return {
    {
        "rest-nvim/rest.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
        },
        config = function(_, opts)
            require("telescope").load_extension("rest")
            vim.g.rest_nvim = opts
        end,
        opts = {
            ui = {
                keybinds = {
                    prev = "<S-Left>",
                    next = "<S-Right>",
                },
            },
        },
    },
}
