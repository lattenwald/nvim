return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "linrongbin16/lsp-progress.nvim",
            "AndreM222/copilot-lualine",
        },
        config = function()
            local lualine = require("lualine")
            local lsp_progress = require("lsp-progress")
            lsp_progress.setup({
                event = "LspProgressUpdate",
            })

            local opts = {
                theme = "auto",
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { current_repo_name, "branch", "diff", "diagnostics" },
                    lualine_c = { "filename", lsp_progress.progress },
                    lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            }

            lualine.setup(opts)

            vim.api.nvim_create_autocmd("User", {
                group = "lualine",
                pattern = "LspProgressUpdate",
                desc = "Update statusline on LSP progress update",
                callback = lualine.refresh,
            })
        end,
    },
}
