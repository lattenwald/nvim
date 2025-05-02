return {
    {
        "folke/trouble.nvim",
        opts = {},
        config = function()
            local trouble = require("trouble")
            vim.keymap.set({ "n", "v" }, "<leader>q", function()
                if trouble.is_open("diagnostics") then
                    trouble.close("diagnostics")
                end
                trouble.open("diagnostics")
            end, { desc = "Diagnostics (Trouble)" })
            vim.keymap.set({ "n", "v" }, "<leader>V", function()
                if trouble.is_open("symbols") then
                    trouble.close("symbols")
                end
                trouble.open("symbols")
            end, { desc = "Symbols (Trouble)" })
        end,
    },
}
