return {
    {
        -- highlight other uses of thw word under cursor
        "RRethy/vim-illuminate",
        config = function()
            local illuminate = require("illuminate")
            vim.keymap.set("n", "<c-down>", illuminate.goto_next_reference, { desc = "Go to next reference" })
            vim.keymap.set("n", "<c-up>", illuminate.goto_prev_reference, { desc = "Go to next reference" })
        end,
    },
}
