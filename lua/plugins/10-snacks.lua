return {
    {
        "folke/snacks.nvim",
        lazy = false,
        priority = 1000,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            explorer = {
                enabled = true,
                replace_netrw = true,
            },
            lazygit = { enabled = true },
            notifier = { enabled = false },
            toggle = { enabled = true },
            input = { enabled = true },
            terminal = { enabled = true },
            picker = {
                enabled = true,
                win = {
                    input = {
                        keys = {
                            ["<s-enter>"] = { "edit_vsplit", mode = { "i", "n" } },
                            ["<c-enter>"] = { "edit_tab", mode = { "i", "n" } },
                            ["<S-PageDown>"] = { "preview_scroll_down", mode = { "i", "n" } },
                            ["<S-PageUp>"] = { "preview_scroll_up", mode = { "i", "n" } },
                            ["<PageDown>"] = { "list_scroll_down", mode = { "i", "n" } },
                            ["<PageUp>"] = { "list_scroll_up", mode = { "i", "n" } },
                        },
                    },
                    list = {
                        keys = {
                            ["<s-enter>"] = { "edit_vsplit", mode = { "i", "n" } },
                            ["<c-enter>"] = { "edit_tab", mode = { "i", "n" } },
                        },
                    },
                },
            },
        },
        -- stylua: ignore
        keys = {
            { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
            { "<leader>b", function() Snacks.picker.buffers({
                win = {
                    input = {
                        keys = {
                            ["<c-d>"] = { "bufdelete", mode = { "n", "i" } },
                            ["<Del>"] = { "bufdelete", mode = { "n" } },
                        }
                    }
                }
            }) end, desc = "Buffers" },
            { "<leader>r", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
            { "<C-`>", function() Snacks.terminal() end, desc = "Terminal", mode = {"n", "i", "v", "t" }  },

            { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },

            { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },

            { "<leader>F", function() Snacks.picker.files() end, desc = "Find Files" },
            { "<leader>f", function() Snacks.picker.git_files() end, desc = "Find Git Files" },

            -- LSP
            { "gd", function() Snacks.picker.lsp_definitions({auto_confirm = false}) end, desc = "Goto Definition" },
            { "gD", function() Snacks.picker.lsp_declarations({auto_confirm = false}) end, desc = "Goto Declaration" },
            { "gr", function() Snacks.picker.lsp_references({auto_confirm = false, include_current = true}) end, nowait = true, desc = "References" },
            { "gI", function() Snacks.picker.lsp_implementations({auto_confirm = false}) end, desc = "Goto Implementation" },
            { "gy", function() Snacks.picker.lsp_type_definitions({auto_confirm = false}) end, desc = "Goto T[y]pe Definition" },
            { "<leader>i", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
            { "<leader>I", function() Snacks.picker.lsp_workspace_symbols({tree = true}) end, desc = "LSP Workspace Symbols" },

            -- git
            { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
            { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
            { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
            { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
            { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
            { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
            { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

            -- Grep
            { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
            { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
            { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },

            -- search
            { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
            { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
            { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
            { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
            { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
            { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
            { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
            { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
            { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
            { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
            { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
            { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
            { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
            { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
            { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
            { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
            { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
            { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
            { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
            { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
        },
        init = function()
            local trim_trailing_ws = true

            local function trim_whitespace()
                if trim_trailing_ws then
                    vim.cmd([[%s/\s\+$//e]])
                end
            end

            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*",
                callback = trim_whitespace,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    local Snacks = require("snacks")
                    -- Setup some globals for debugging (lazy-loaded)
                    _G.dd = function(...)
                        Snacks.debug.inspect(...)
                    end
                    _G.bt = function()
                        Snacks.debug.backtrace()
                    end
                    vim.print = _G.dd -- Override print to use snacks for `:=` command

                    -- Create some toggle mappings
                    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                    Snacks.toggle.diagnostics():map("<leader>ud")
                    Snacks.toggle.line_number():map("<leader>ul")
                    Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
                    Snacks.toggle.treesitter():map("<leader>uT")
                    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
                    Snacks.toggle.inlay_hints():map("<leader>uh")
                    Snacks.toggle.indent():map("<leader>ug")
                    Snacks.toggle.dim():map("<leader>uD")
                    Snacks.toggle.option("list", { name = "Whitespaces" }):map("<leader>uS")
                    Snacks.toggle
                        .new({
                            id = "trim_trailing_ws",
                            name = "Trim Trailing Whitespace on Save",
                            get = function()
                                return trim_trailing_ws
                            end,
                            set = function(state)
                                trim_trailing_ws = state
                            end,
                            icon = { enabled = "󰛗", disabled = "󰛖" }, -- optional, pick icons you like
                            color = { enabled = "green", disabled = "yellow" }, -- optional
                        })
                        :map("<leader>uW")
                end,
            })
        end,
    },
}
