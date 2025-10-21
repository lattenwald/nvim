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
            terminal = {
                enabled = true,
                keys = {
                    q = "hide",
                    gf = function(self)
                        local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
                        if f == "" then
                            Snacks.notify.warn("No file under cursor")
                        else
                            self:hide()
                            vim.schedule(function()
                                vim.cmd("e " .. f)
                            end)
                        end
                    end,
                    term_normal = {
                        "<esc>",
                        function(self)
                            self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
                            if self.esc_timer:is_active() then
                                self.esc_timer:stop()
                                vim.cmd("stopinsert")
                            else
                                self.esc_timer:start(300, 0, function() end)
                                return "<C-\\><C-n>"
                            end
                        end,
                        mode = "t",
                        expr = true,
                        desc = "Double escape to normal mode",
                    },
                },
            },
            picker = {
                enabled = true,
                root = {
                    patterns = { ".git", "project-root" },
                },
                win = {
                    input = {
                        keys = {
                            ["<s-enter>"] = { "edit_vsplit", mode = { "i", "n" } },
                            ["<c-s-enter>"] = { "edit_split", mode = { "i", "n" } },
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

            -- AI Helpers
            { "<leader>s", nil, desc = "AI Helpers" },
            { "<leader>ss", function() require("config.ai_helpers").switch_helper() end, desc = "Switch AI Helper", mode = {"n", "v"} },
            { "<leader>st", function() require("config.ai_helpers").toggle_terminal() end, desc = "Toggle AI Terminal", mode = {"n", "i", "v"} },
            { "<C-.>", function() require("config.ai_helpers").toggle_terminal() end, desc = "Toggle AI Terminal", mode = {"n", "i", "v", "t" } },
            { "<leader>sv", function() require("config.ai_helpers").send_selection() end, mode = "v", desc = "Send Selection to AI" },
            { "<leader>sb", function() require("config.ai_helpers").send_buffer() end, desc = "Send Buffer to AI", mode = "n" },


            { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },

            { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },

            { "<leader>F", function() Snacks.picker.files() end, desc = "Find Files" },

            { "<leader>f", function()
                local current_dir = vim.fn.expand("%:p:h")
                local project_root = require("config.utils").find_project_root(current_dir, { ".git", "project-root" })

                if project_root then
                    local cwd = project_root
                    local ok = pcall(Snacks.picker.git_files, { cwd = cwd })
                    if not ok then
                        Snacks.picker.files({ cwd = cwd })
                    end
                else
                    Snacks.picker.files({ cwd = current_dir })
                end
            end, desc = "Find Files (Git/Project Root)" },

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
            { "<leader>Sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
            { "<leader>SB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
            { "<leader>Sg", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>Sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },

            -- search
            { '<leader>S"', function() Snacks.picker.registers() end, desc = "Registers" },
            { '<leader>S/', function() Snacks.picker.search_history() end, desc = "Search History" },
            { "<leader>Sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
            { "<leader>Sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
            { "<leader>Sc", function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>SC", function() Snacks.picker.commands() end, desc = "Commands" },
            { "<leader>Sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
            { "<leader>SD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
            { "<leader>Sh", function() Snacks.picker.help() end, desc = "Help Pages" },
            { "<leader>SH", function() Snacks.picker.highlights() end, desc = "Highlights" },
            { "<leader>Si", function() Snacks.picker.icons() end, desc = "Icons" },
            { "<leader>Sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
            { "<leader>Sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
            { "<leader>Sl", function() Snacks.picker.loclist() end, desc = "Location List" },
            { "<leader>Sm", function() Snacks.picker.marks() end, desc = "Marks" },
            { "<leader>SM", function() Snacks.picker.man() end, desc = "Man Pages" },
            { "<leader>Sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
            { "<leader>Sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
            { "<leader>SR", function() Snacks.picker.resume() end, desc = "Resume" },
            { "<leader>Su", function() Snacks.picker.undo() end, desc = "Undo History" },
            { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
        },
        init = function()
            -- Setup AI helpers
            require("config.ai_helpers").setup({
                storage = "file", -- or "file" for persistence across sessions
                default_helper = "gemini",
                terminal = {
                    type = "split", -- "float" or "split"
                    position = "right", -- for split: "right", "left", "top", "bottom"
                    size = 0.4, -- for split: fraction of screen (0.0-1.0)
                },
            })

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

            -- Map Shift-Enter to <C-J> for Claude Code and Cursor to submit prompts,
            -- and to escaped <CR> for other terminals
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "*",
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    vim.keymap.set("t", "<S-CR>", function()
                        local buf = vim.api.nvim_get_current_buf()
                        local bufname = vim.fn.bufname(buf)

                        if bufname:match(":claude$") then
                            return "<C-J>"
                        end

                        local ai_helpers = require("config.ai_helpers")
                        local helper_name = ai_helpers.get_helper_from_buffer(buf)

                        if helper_name == "cursor" then
                            return "<C-J>"
                        else
                            return "\\<CR>"
                        end
                    end, { buffer = bufnr, expr = true, desc = "Smart enter: <C-J> for cursor and claude, \\<CR> for others" })

                    -- Map Ctrl+. to toggle AI helper terminal in terminal mode
                    vim.keymap.set("t", "<C-.>", function()
                        require("config.ai_helpers").toggle_terminal()
                    end, { buffer = bufnr, desc = "Toggle AI Terminal" })
                end,
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
