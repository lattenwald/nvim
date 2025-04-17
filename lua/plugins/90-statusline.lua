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
                options = {
                    always_show_tabline = true,
                    globalstatus = true,
                },
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
    {
        "nanozuki/tabby.nvim",
        -- enabled = false,
        -- event = 'VimEnter',
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            preset = "active_wins_at_tail",
            option = {
                tab_name = {
                    name_fallback = function(tabid)
                        return tabid
                    end,
                },
                buf_name = {
                    mode = "relative",
                },
            },
        },
        config = function(_, opts)
            require("tabby").setup(opts)
            -- move tabs
            vim.api.nvim_set_keymap("n", "<C-S-PageDown>", ":tabmove +1<cr>", { desc = "Move tab right" })
            vim.api.nvim_set_keymap("n", "<C-S-PageUp>", ":tabmove -1<cr>", { desc = "Move tab left" })
        end,
    },
    {
        "akinsho/bufferline.nvim",
        enabled = false,
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            options = {
                mode = "tabs",
            },
        },
    },
    {
        "romgrk/barbar.nvim",
        enabled = false,
        dependencies = {
            "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
        },
        init = function()
            vim.g.barbar_auto_setup = false
        end,
        opts = {
            animation = false,
            icons = {
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true },
                    [vim.diagnostic.severity.WARN] = { enabled = true },
                    [vim.diagnostic.severity.INFO] = { enabled = true },
                    [vim.diagnostic.severity.HINT] = { enabled = true },
                },
            },
        },
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
