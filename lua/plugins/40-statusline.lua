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
                    lualine_b = { require("config.utils").current_repo_name, "branch", "diff", "diagnostics" },
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
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function(_, opts)
            require("tabby").setup(opts)
            -- move tabs
            vim.keymap.set("n", "<C-S-PageDown>", ":tabmove +1<enter>", { desc = "Move tab right" })
            vim.keymap.set("n", "<C-S-PageUp>", ":tabmove -1<enter>", { desc = "Move tab left" })

            local function get_diagnostic_counts(bufnr)
                local diagnostics = vim.diagnostic.get(bufnr)
                local counts = {
                    info = 0,
                    warning = 0,
                    error = 0,
                }
                for _, diag in ipairs(diagnostics) do
                    if diag.severity == vim.diagnostic.severity.INFO then
                        counts.info = counts.info + 1
                    elseif diag.severity == vim.diagnostic.severity.WARN then
                        counts.warning = counts.warning + 1
                    elseif diag.severity == vim.diagnostic.severity.ERROR then
                        counts.error = counts.error + 1
                    end
                end
                return counts
            end

            local theme = {
                fill = "TabLineFill",
                head = "TabLine",
                -- current = "MiniTablineCurrent",
                current = "lualine_a_insert",
                tab = "TabLine",
                tail = "TabLine",
            }
            require("tabby").setup({
                line = function(line)
                    return {
                        {
                            { "  ", hl = theme.head },
                            line.sep("", theme.head, theme.fill),
                        },
                        line.tabs().foreach(function(tab)
                            local hl = tab.is_current() and theme.current or theme.tab
                            return {
                                line.sep("", hl, theme.fill),
                                tab.is_current() and "" or "󰆣",
                                tab.number(),
                                tab.name(),
                                line.sep("", hl, theme.fill),
                                hl = hl,
                                margin = " ",
                            }
                        end),
                        line.spacer(),
                        line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                            local diag = get_diagnostic_counts(win.buf().id)
                            local hl = theme.tab
                            if win.is_current() then
                                if diag.error > 0 then
                                    hl = "TodoBgXXX"
                                elseif diag.warning > 0 then
                                    hl = "TodoBgWarn"
                                elseif diag.info > 0 then
                                    hl = "TodoBgTODO"
                                else
                                    hl = theme.current
                                end
                            else
                                if diag.error > 0 then
                                    hl = "lualine_b_diagnostics_error_normal"
                                elseif diag.warning > 0 then
                                    hl = "lualine_b_diagnostics_warn_normal"
                                elseif diag.info > 0 then
                                    hl = "lualine_b_diagnostics_info_normal"
                                else
                                    hl = theme.tab
                                end
                            end
                            return {
                                line.sep("", hl, theme.fill),
                                win.is_current() and "" or "",
                                win.buf().id,
                                win.buf_name(),
                                diag.error > 0 and "" or "",
                                diag.warning > 0 and "" or "",
                                diag.info > 0 and "" or "",
                                win.buf().is_changed() and "+" or "",
                                line.sep("", hl, theme.fill),
                                hl = hl,
                                margin = " ",
                            }
                        end),
                        {
                            line.sep("", theme.tail, theme.fill),
                            { "  ", hl = theme.tail },
                        },
                        hl = theme.fill,
                    }
                end,
                -- option = {}, -- setup modules' option,
            })
        end,
    },
}
