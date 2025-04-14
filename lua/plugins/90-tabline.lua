return {
    {
        "akinsho/bufferline.nvim",
        enabled = false,
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
    },
    {
        "romgrk/barbar.nvim",
        -- enabled = false,
        dependencies = {
            "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
        },
        init = function()
            vim.g.barbar_auto_setup = false
        end,
        opts = {},
        config = function(_, opts)
            require("barbar").setup(opts)
            vim.keymap.set("n", "<C-PageDown>", "<Cmd>BufferNext<CR>", { desc = "Next tab" })
            vim.keymap.set("n", "<C-PageUp>", "<Cmd>BufferPrev<CR>", { desc = "Previous tab" })

            vim.keymap.set("n", "<C-S-PageDown>", "<Cmd>BufferMoveNext<CR>", { desc = "Move tab to the right" })
            vim.keymap.set("n", "<C-S-PageUp>", "<Cmd>BufferMovePrev<CR>", { desc = "Move tab to the left" })

            vim.keymap.set("n", "<leader>X", "<Cmd>BufferClose<CR>", { desc = "Close tab" })
        end,
    },
}
