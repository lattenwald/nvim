return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            -- stylua: ignore
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                vim.keymap.set("n", "hs",         function() gitsigns.stage_hunk() end, { desc = "Stage hunk", buffer = bufnr })
                vim.keymap.set("n", "<leader>hp", function() gitsigns.preview_hunk() end, { desc = "Preview hunk", buffer = bufnr })
                -- Pick a branch/revision as the gitsigns diff base (global), e.g. diff against master instead of the index
                vim.keymap.set("n", "<leader>hb", function()
                    Snacks.picker.git_branches({
                        confirm = function(picker, item)
                            picker:close()
                            if item then
                                gitsigns.change_base(item.branch or item.commit, true)
                            end
                        end,
                    })
                end, { desc = "Gitsigns: pick diff base", buffer = bufnr })
                vim.keymap.set("n", "<leader>hr", function() gitsigns.reset_hunk() end, { desc = "Reset hunk", buffer = bufnr })
                vim.keymap.set("n", "<leader>hS", function() gitsigns.stage_buffer() end, { desc = "Stage buffer", buffer = bufnr })
                vim.keymap.set("n", "<leader>hu", function() gitsigns.undo_stage_hunk() end, { desc = "Undo stage hunk", buffer = bufnr })
                vim.keymap.set("n", "]c",         function() gitsigns.next_hunk({ target = "all" }) end, { desc = "Next hunk", buffer = bufnr })
                vim.keymap.set("n", "[c",         function() gitsigns.prev_hunk({ target = "all" }) end, { desc = "Prev hunk", buffer = bufnr })
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
