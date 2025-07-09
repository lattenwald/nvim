return {
    {
        "ravitemer/mcphub.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        build = "npm install -g mcp-hub@latest",
        opts = {
            config = vim.fn.expand("~/.config/nvim/mcpservers.json"),
            auto_approve = false,
            extensions = {
                avante = {
                    make_slash_commands = true,
                },
                codecompanion = {
                    make_slash_commands = true,
                },
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
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            {
                "zbirenbaum/copilot.lua",
            },
            {
                "nvim-lua/plenary.nvim",
                branch = "master",
            },
        },
        build = "make tiktoken",
        opts = {
            window = {
                layout = "vertical",
                width = 0.35,
            },
        },
    },
    {
        "coder/claudecode.nvim",
        -- enabled = false,
        dependencies = { "folke/snacks.nvim" },
        opts = {
            terminal = {
                split_width_percentage = 0.4,
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
            -- Diff management (global keymaps)
            { "<leader>wa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>wd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    },
    {
        "greggh/claude-code.nvim",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for git operations
        },
        opts = {
            window = {
                split_ratio = 0.4,
                position = "vertical",
            },
            -- Keymaps
            keymaps = {
                toggle = {
                    normal = "<C-,>", -- Normal mode keymap for toggling Claude Code, false to disable
                    terminal = "<C-,>", -- Terminal mode keymap for toggling Claude Code, false to disable
                    variants = {
                        continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
                        verbose = "<leader>cV", -- Normal mode keymap for Claude Code with verbose flag
                    },
                },
                window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
                scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
            },
        },
    },
    {
        "olimorris/codecompanion.nvim",
        lazy = true,
        cmd = "CodeCompanionActions",
        opts = {
            strategies = {
                chat = {
                    -- adapter = "copilot",
                    adapter = "anthropic",
                    -- provider = {
                    --     api_key = os.getenv("ANTHROPIC_API_KEY"),
                    --     -- model = "claude-3-opus-20240229",
                    -- },
                },
            },
            extensions = {
                mcphub = {
                    callback = "mcphub.extensions.codecompanion",
                    opts = {
                        make_vars = true,
                        make_slash_commands = true,
                        show_result_in_chat = true,
                    },
                },
            },
            keymaps = {
                clear_chat = "xx",
                close = {
                    modes = { n = "<C-x>", i = "<C-x>" },
                    opts = {},
                },
            },
            display = {
                chat = {
                    window = {
                        position = "right",
                        width = 0.4,
                    },
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- {
            --     "echasnovski/mini.diff",
            --     config = function()
            --         local diff = require("mini.diff")
            --         diff.setup({
            --             source = diff.gen_source.none(),
            --         })
            --     end,
            -- },
            {
                "HakonHarnes/img-clip.nvim",
                opts = {
                    filetypes = {
                        codecompanion = {
                            prompt_for_file_name = false,
                            template = "[Image]($FILE_PATH)",
                            use_absolute_path = true,
                        },
                    },
                },
            },
        },
    },
}
