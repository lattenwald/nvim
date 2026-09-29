return {
    {
        -- Upstream private since 2026-09-26; newer commits need kulala-core 1.x (unavailable), local core is 0.37.0
        -- "mistweaverco/kulala.nvim",
        "lattenwald/kulala.nvim",
        branch = "mistweaverco-main",
        commit = "dcad056448773ae5b54cadbfdbd188a599cfebd3",
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
            { "<leader>Rb", desc = "Open scratchpad" },
            { "<leader>Re", desc = "Select environment" },
        },
        ft = { "http", "rest" },
        opts = {
            global_keymaps = true,
            global_keymaps_prefix = "<leader>R",
            kulala_keymaps_prefix = "",
            -- Set path disables unverified kulala-core auto-download
            kulala_core = { path = vim.fn.stdpath("data") .. "/kulala.nvim/bin/kulala-core" },
        },
    },
}
