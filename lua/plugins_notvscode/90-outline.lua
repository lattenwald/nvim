return {
    {
        "stevearc/aerial.nvim",
        enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup({
                layout = {
                    default_direction = "prefer_right",
                },
                backends = {
                    ["_"] = { "lsp", "treesitter", "markdown", "man" },
                    -- vimwiki = {"markdown"},
                },
            })
            vim.keymap.set("n", "<leader>V", "<cmd>AerialToggle<cr>", { desc = "Toggle code outline" })
        end,
    },
    {
        "simrat39/symbols-outline.nvim",
        enabled = false,
        opts = {},
        config = function()
            require("symbols-outline").setup()
            vim.keymap.set("n", "<leader>V", "<cmd>SymbolsOutline<cr>", { desc = "Toggle code outline" })
        end,
    },
    {
        "Bekaboo/dropbar.nvim",
        enabled = false,
        opts = {},
    },
}
