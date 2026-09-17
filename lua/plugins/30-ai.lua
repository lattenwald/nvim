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
    {
        -- Own spec so helper keys don't load claudecode.nvim (and its websocket server)
        "ai_helpers",
        virtual = true,
        cmd = { "AIHelperManage", "AIHelperToggle", "AIHelperSend", "AIHelperSendBuffer" },
        opts = {
            terminal = {
                type = "split", -- "float" or "split"
                position = "right", -- for split: "right", "left", "top", "bottom"
                size = 0.4, -- for split: fraction of screen (0.0-1.0)
            },
        },
        config = function(_, opts)
            require("config.ai_helpers").setup(opts)
        end,
        keys = {
            { "<C-.>", "<cmd>AIHelperToggle<cr>", mode = { "n", "i", "v", "t" }, desc = "Toggle AI Terminal" },
            { "<leader>.", "<cmd>AIHelperToggle<cr>", mode = { "n", "v" }, desc = "Toggle AI Terminal" },
            {
                "<C-S-.>",
                function()
                    require("config.ai_helpers").hide_all()
                end,
                mode = { "n", "i", "v", "t" },
                desc = "Hide All AI Terminals",
            },
            { "<leader>wt", "<cmd>AIHelperToggle<cr>", mode = { "n", "v" }, desc = "Toggle AI Helper Terminal" },
            { "<leader>wh", "<cmd>AIHelperManage<cr>", mode = { "n", "v" }, desc = "Manage AI Helpers" },
        },
    },
}
