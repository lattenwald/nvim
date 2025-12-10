return {
    {
        -- "ravitemer/mcphub.nvim",
        "lattenwald/mcphub.nvim", -- forked version to soften version mismatch behavior
        dependencies = { "nvim-lua/plenary.nvim" },
        -- build = "npm install -g mcp-hub@latest",
        -- build = "npm install -g github:donadiosolutions/mcp-hub#feat/stream-http",
        opts = {
            config = vim.fn.expand("~/.mcp-hub/config.json"),
            auto_approve = false,
            log = {
                level = vim.log.levels.DEBUG,
                to_file = false,
                file_path = nil,
                prefix = "MCPHub",
            },
        },
    },
    {
        "zbirenbaum/copilot.lua",
        lazy = true,
        cmd = "Copilot",
        opts = {
            suggestion = {
                enabled = false,
            },
            panel = {
                enabled = false,
                auto_refresh = true,
            },
        },
        config = function(_, opts)
            local avante_opts_file = vim.fn.stdpath("data") .. "/avante_opts.yaml"
            local yaml_opts = require("config.utils").load_yaml(avante_opts_file)
            if yaml_opts and yaml_opts["copilot"] then
                opts = vim.tbl_deep_extend("force", opts or {}, yaml_opts.copilot or {})
            end
            require("copilot").setup(opts)
        end,
    },
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            terminal = {
                split_width_percentage = 0.4,
                provider = "snacks",
                provider_opts = {
                    external_terminal_cmd = "alacritty -e %s", -- Replace with your preferred terminal program. %s is replaced with claude command
                },
            },
        },
        config = function(_, opts)
            require("claudecode").setup(opts)

            -- Set up buffer-local keymaps for claude-code diff context
            vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "OptionSet" }, {
                group = vim.api.nvim_create_augroup("ClaudeCodeDiffKeymaps", { clear = true }),
                pattern = { "*", "diff" },
                callback = function()
                    local current_buf = vim.api.nvim_get_current_buf()

                    -- Multiple ways to detect diff mode
                    local is_diff_mode = vim.wo.diff
                        or vim.opt_local.diff:get()
                        or vim.api.nvim_win_get_option(0, "diff")
                        or vim.fn.getwinvar(0, "&diff") == 1

                    -- Check if we're in a claude-code diff context
                    local is_claude_diff = vim.b[current_buf].claudecode_diff_tab_name ~= nil
                        or vim.b[current_buf].claudecode_diff_new_win ~= nil
                        or (vim.fn.bufname() or ""):match("%.new$")
                        or (vim.fn.bufname() or ""):match("%(New%)")
                        or (vim.fn.bufname() or ""):match("%(proposed%)")

                    if is_diff_mode and is_claude_diff then
                        -- Buffer-local keymaps matching gitsigns pattern
                        local opts = { buffer = current_buf, silent = true }

                        -- Navigation (like gitsigns ]c/[c)
                        vim.keymap.set("n", "]c", function()
                            if vim.wo.diff then
                                vim.cmd.normal({ "]c", bang = true })
                            end
                        end, vim.tbl_extend("force", opts, { desc = "Next diff hunk" }))

                        vim.keymap.set("n", "[c", function()
                            if vim.wo.diff then
                                vim.cmd.normal({ "[c", bang = true })
                            end
                        end, vim.tbl_extend("force", opts, { desc = "Previous diff hunk" }))

                        -- Hunk operations (like gitsigns h* pattern)
                        vim.keymap.set("n", "hs", "<cmd>ClaudeCodeDiffAccept<cr>", vim.tbl_extend("force", opts, { desc = "Accept (stage) diff" }))
                        vim.keymap.set(
                            "n",
                            "<leader>hr",
                            "<cmd>ClaudeCodeDiffDeny<cr>",
                            vim.tbl_extend("force", opts, { desc = "Reset (deny) diff" })
                        )
                        vim.keymap.set("n", "<leader>hp", function()
                            -- Preview current hunk in diff mode
                            if vim.wo.diff then
                                vim.cmd("normal! zR") -- Open all folds to see diff
                            end
                        end, vim.tbl_extend("force", opts, { desc = "Preview diff hunk" }))

                        -- Additional claude-code specific operations
                        vim.keymap.set(
                            "n",
                            "<leader>ha",
                            "<cmd>ClaudeCodeDiffAccept<cr>",
                            vim.tbl_extend("force", opts, { desc = "Accept all diffs" })
                        )
                        vim.keymap.set("n", "<leader>hd", "<cmd>ClaudeCodeDiffDeny<cr>", vim.tbl_extend("force", opts, { desc = "Deny all diffs" }))

                        vim.keymap.set("n", "<leader>wa", "<cmd>ClaudeCodeDiffAccept<cr>", vim.tbl_extend("force", opts, { desc = "Accept diff" }))
                        vim.keymap.set("n", "<leader>wd", "<cmd>ClaudeCodeDiffDeny<cr>", vim.tbl_extend("force", opts, { desc = "Deny diff" }))
                    end
                end,
            })
        end,
        keys = {
            { "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>w", nil, desc = "AI/Claude Code" },
            { "<leader>wc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>wf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>wr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>wC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>wb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>ws", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
                "<leader>ws",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil" },
            },
        },
    },
}
