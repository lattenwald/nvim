return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            -- stylua: ignore
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                vim.keymap.set("n", "hs",         function() gitsigns.stage_hunk() end, { desc = "Stage hunk", buffer = bufnr })
                vim.keymap.set("n", "<leader>hp", function() gitsigns.preview_hunk() end, { desc = "Preview hunk", buffer = bufnr })
                vim.keymap.set("n", "<leader>hr", function() gitsigns.reset_hunk() end, { desc = "Reset hunk", buffer = bufnr })
                vim.keymap.set("n", "<leader>hS", function() gitsigns.stage_buffer() end, { desc = "Stage buffer", buffer = bufnr })
                vim.keymap.set("n", "<leader>hu", function() gitsigns.undo_stage_hunk() end, { desc = "Undo stage hunk", buffer = bufnr })
                vim.keymap.set("n", "]c",         function() gitsigns.next_hunk() end, { desc = "Next hunk", buffer = bufnr })
                vim.keymap.set("n", "[c",         function() gitsigns.prev_hunk() end, { desc = "Prev hunk", buffer = bufnr })
            end,
        },
    },
    {
        "sindrets/diffview.nvim",
    },
    {
        "tpope/vim-fugitive",
    },
}

