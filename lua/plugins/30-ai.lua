return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            env = {
                CLAUDE_CODE_DISABLE_TERMINAL_TITLE = "1",
            },
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

            if require("config.ai_helpers").claude_has_personal_config() then
                vim.api.nvim_create_user_command("ClaudeAccount", function()
                    require("config.ai_helpers").claude_select_account()
                end, { desc = "Switch Claude subscription" })
            end

            -- Buffer-local diff keymaps, matching the gitsigns h* pattern
            local diff_keys = {
                ["hs"] = { "<cmd>ClaudeCodeDiffAccept<cr>", "Accept (stage) diff" },
                ["<leader>ha"] = { "<cmd>ClaudeCodeDiffAccept<cr>", "Accept all diffs" },
                ["<leader>wa"] = { "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff" },
                ["<leader>hr"] = { "<cmd>ClaudeCodeDiffDeny<cr>", "Reset (deny) diff" },
                ["<leader>hd"] = { "<cmd>ClaudeCodeDiffDeny<cr>", "Deny all diffs" },
                ["<leader>wd"] = { "<cmd>ClaudeCodeDiffDeny<cr>", "Deny diff" },
                ["<leader>hp"] = { "<cmd>normal! zR<cr>", "Open all folds in diff" },
            }

            -- ClaudeCodeDiffOpened fires once per diff with the proposed-edit window (see claudecode README)
            vim.api.nvim_create_autocmd("User", {
                group = vim.api.nvim_create_augroup("ClaudeCodeDiffKeymaps", { clear = true }),
                pattern = "ClaudeCodeDiffOpened",
                callback = function(ev)
                    local win = ev.data and ev.data.diff_window
                    if not (win and vim.api.nvim_win_is_valid(win)) then
                        return
                    end
                    local buf = vim.api.nvim_win_get_buf(win)
                    for lhs, spec in pairs(diff_keys) do
                        vim.keymap.set("n", lhs, spec[1], { buffer = buf, silent = true, desc = spec[2] })
                    end
                end,
            })
        end,
        keys = {
            {
                "<C-,>",
                function()
                    require("config.ai_helpers").claude_toggle()
                end,
                mode = { "n", "t" },
                desc = "Toggle Claude",
            },
            {
                "<leader>,",
                function()
                    require("config.ai_helpers").claude_toggle()
                end,
                desc = "Toggle Claude",
            },
            { "<leader>w", nil, desc = "AI/Claude Code" },
            {
                "<leader>wc",
                function()
                    require("config.ai_helpers").claude_toggle()
                end,
                desc = "Toggle Claude",
            },
            { "<leader>wf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            {
                "<leader>wr",
                function()
                    require("config.ai_helpers").claude_toggle("ClaudeCode --resume")
                end,
                desc = "Resume Claude",
            },
            {
                "<leader>wC",
                function()
                    require("config.ai_helpers").claude_toggle("ClaudeCode --continue")
                end,
                desc = "Continue Claude",
            },
            {
                "<leader>wA",
                function()
                    require("config.ai_helpers").claude_select_account()
                end,
                desc = "Claude Account",
            },
            {
                "<leader>wt",
                function()
                    require("config.ai_helpers").toggle_terminal()
                end,
                desc = "Toggle AI Helper Terminal",
                mode = { "n", "v" },
            },
            {
                "<leader>wh",
                function()
                    require("config.ai_helpers").switch_helper()
                end,
                desc = "Choose AI Helper",
                mode = { "n", "v" },
            },
            {
                "<leader>wb",
                function()
                    require("config.ai_helpers").smart_send_buffer()
                end,
                desc = "Send buffer to AI (smart)",
            },
            {
                "<leader>ws",
                function()
                    require("config.ai_helpers").smart_send_selection()
                end,
                mode = "v",
                desc = "Send selection to AI (smart)",
            },
            {
                "<leader>ws",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil" },
            },
        },
    },
}
