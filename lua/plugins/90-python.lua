return {
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require("dap-python").setup("uv")
        end,
    },
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap",
            "mfussenegger/nvim-dap-python", --optional
        },
        lazy = false,
        opts = {
            search = {},
            options = {
                picker = "snacks",

                on_venv_activate_callback = function()
                    local python = require("venv-selector").python()
                    vim.notify("Activated venv: " .. python, {
                        title = "Venv Selector",
                    })
                end,
            },
        },
    },
}
