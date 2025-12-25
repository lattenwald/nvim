return {
    {
        "rest-nvim/rest.nvim",
        ft = "http",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "j-hui/fidget.nvim",
        },
        keys = {
            { "<C-r>", "<cmd>Rest run<CR>", desc = "Run REST request", ft = "http" },
            { "<C-S-r>", ":Rest run ", desc = "Run named REST request", ft = "http" },
        },
        config = function(_, opts)
            vim.g.rest_nvim = opts
        end,
        opts = {
            ui = {
                keybinds = {
                    prev = "<S-Left>",
                    next = "<S-Right>",
                },
            },
            cookies = {
                enable = true,
                path = vim.fn.expand("$HOME/REST/rest-nvim.cookies"),
            },
        },
    },
}
