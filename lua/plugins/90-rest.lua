return {
    {
        "lattenwald/wire.nvim",
        ft = "http",
        cmd = "Wire",
        init = function()
            vim.lsp.enable("wire")
        end,
        opts = {
            mask = false,
            trust = { "/" },
        },
        keys = {
            { "<leader>Rs", "<cmd>Wire send<cr>", desc = "Send request" },
            { "<leader>Ra", "<cmd>Wire all<cr>", desc = "Send all requests" },
            { "<leader>Rb", "<cmd>Wire scratch<cr>", desc = "Scratchpad" },
            { "<leader>Re", "<cmd>Wire env<cr>", desc = "Select environment" },
            { "<leader>Rc", "<cmd>Wire cancel<cr>", desc = "Cancel run" },
            { "<leader>Ro", "<cmd>Wire open<cr>", desc = "Open response window" },
            { "<leader>Ry", "<cmd>Wire yank<cr>", desc = "Yank request as curl" },
        },
    },
}
