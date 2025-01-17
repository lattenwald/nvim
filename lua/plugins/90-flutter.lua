return {
    {
        "akinsho/flutter-tools.nvim",
        enabled = false,
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim", -- optional for vim.ui.select
        },
        opts = {
            flutter_path = "/home/qalex/flutter/bin/flutter",
            ui = {
                notification_style = "native",
            },
            lsp = {
                color = {
                    enabled = true,
                },
                on_attach = function()
                    vim.keymap.set(
                        "n",
                        "<leader>v",
                        "<cmd>FlutterOutlineToggle<cr>",
                        { desc = "LSP outline", buffer = true }
                    )
                end,
            },
        },
    },
}
