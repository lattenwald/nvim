return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {},
        config = function(_, opts)
            require("gitsigns").setup(opts)

            -- Setup keymaps
            vim.keymap.set("n", "hs", '<cmd>lua require"gitsigns".stage_hunk()<CR>', { desc = "Stage hunk" })
            vim.keymap.set(
                "n",
                "<leader>hp",
                '<cmd>lua require"gitsigns".preview_hunk()<CR>',
                { desc = "Preview hunk" }
            )
            vim.keymap.set("n", "<leader>hr", '<cmd>lua require"gitsigns".reset_hunk()<CR>', { desc = "Reset hunk" })
            vim.keymap.set("n", "<leader>hS", '<cmd>lua require"gitsigns".stagefer()<CR>', { desc = "Stage buffer" })
            vim.keymap.set(
                "n",
                "<leader>hu",
                '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
                { desc = "Undo stage hunk" }
            )
            vim.keymap.set("n", "]c", '<cmd>lua require"gitsigns".next_hunk()<CR>', { desc = "Next hunk" })
            vim.keymap.set("n", "[c", '<cmd>lua require"gitsigns".prev_hunk()<CR>', { desc = "Next hunk" })
        end,
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
        opts = {
            enabled = false,
        },
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
