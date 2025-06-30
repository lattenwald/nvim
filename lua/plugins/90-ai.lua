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
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = function()
            require("claudecode").setup()

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
        "yetone/avante.nvim",
        lazy = true,
        enabled = false,
        cmd = "AvanteToggle",
        version = false, -- Never set this value to "*"! Never!
        build = "make",
        opts = {
            -- provider = "copilot",
            provider = "claude",
            file_selector = {
                provider = "snacks",
                provider_opts = {
                    get_filepaths = function(params)
                        local cwd = params.cwd
                        local cmd = string.format("fd --base-directory '%s'", vim.fn.fnameescape(cwd))
                        local output = vim.fn.system(cmd)
                        local filepaths = vim.split(output, "\n", { trimempty = true })
                        return filepaths
                    end,
                },
            },
            -- system_prompt as function ensures LLM always has latest MCP server state
            -- This is evaluated for every message, even in existing chats
            system_prompt = function()
                local hub = require("mcphub").get_hub_instance()
                return hub and hub:get_active_servers_prompt() or ""
            end,
            -- Using function prevents requiring mcphub before it's loaded
            custom_tools = function()
                return {
                    require("mcphub.extensions.avante").mcp_tool(),
                }
            end,
            -- Disable tools conflicting with mcphub tools
            disabled_tools = {
                "list_files", -- Built-in file operations
                "search_files",
                "read_file",
                "create_file",
                "rename_file",
                "delete_file",
                "create_dir",
                "rename_dir",
                "delete_dir",
                "bash", -- Built-in terminal access
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",

            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            -- "Kaiser-Yang/blink-cmp-avante",
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
        },
        config = function(_, opts)
            local avante_opts_file = vim.fn.stdpath("data") .. "/avante_opts.yaml"
            local yaml_opts = require("config.utils").load_yaml(avante_opts_file)
            if yaml_opts then
                if not opts.providers then
                    opts.providers = {}
                end
                opts.providers = vim.tbl_deep_extend("force", opts.providers, yaml_opts or {})
            end
            require("avante").setup(opts)
        end,
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
