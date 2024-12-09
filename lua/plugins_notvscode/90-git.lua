return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {},
    },
    {
        "tpope/vim-fugitive",
    },
    {
        "sindrets/diffview.nvim",
        opts = {},
    },
    {
        "f-person/git-blame.nvim",
        event = "VeryLazy",
    },
    {
        "kdheepak/lazygit.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            vim.g.lazygit_floating_window_use_plenary = 1
            require("telescope").load_extension("lazygit")
            vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
            vim.keymap.set("n", "<leader>gG", function()
                require("telescope").extensions.lazygit.lazygit()
            end, { desc = "LazyGit (Telescope)" })
        end,
    },
}
