return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        opts = {},
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    if not ft or ft == "" then
                        return
                    end
                    local lang = vim.treesitter.language.get_lang(ft)
                    if not lang then
                        return
                    end
                    if vim.treesitter.language.add(lang) then
                        require("nvim-treesitter").install({ lang })
                        vim.treesitter.stop(args.buf)
                        vim.treesitter.start()
                    end
                end,
            })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        branch = "main",
        opts = {
            opts = {
                enable_close_on_slash = true,
            },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        dependencies = {
            "echasnovski/mini.icons",
            "nvim-tree/nvim-web-devicons",
        },
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = true })
                end,
                desc = "Keymaps (which-key)",
            },
            {
                "<leader>/",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer-local keymaps (which-key)",
            },
        },
    },
    {
        "mikavilpas/yazi.nvim",
        keys = {
            -- 👇 in this section, choose your own keymappings!
            {
                "<leader>z",
                "<cmd>Yazi<enter>",
                desc = "Open yazi at the current file",
            },
            {
                -- NOTE: this requires a version of yazi that includes
                -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
                "<leader>-",
                "<cmd>Yazi toggle<enter>",
                desc = "Resume the last yazi session",
            },
        },
        ---@type YaziConfig
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = true,

            -- enable these if you are using the latest version of yazi
            use_ya_for_events_reading = true,
            use_yazi_client_id_flag = true,

            keymaps = {
                show_help = "g?",
                open_file_in_vertical_split = "<s-enter>",
                open_file_in_tab = "<c-enter>",
            },
        },
    },
    {
        "folke/noice.nvim",
        event = nil,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            cmdline = { enabled = true },
            popupmenu = { enabled = true },
            notify = { enabled = true },

            messages = { enabled = true },

            hover = {
                enabled = true,
                silent = false, -- set to true to not show a message if hover is not available
                view = nil, -- when nil, use defaults from documentation
                ---@type NoiceViewOptions
                opts = { -- merged with defaults from documentation
                    max_width = 60,
                },
            },

            -- defaults for hover and signature help
            documentation = {
                view = "hover",
                ---@type NoiceViewOptions
                opts = {
                    lang = "markdown",
                    replace = true,
                    render = "plain",
                    format = { "{message}" },
                    win_options = { concealcursor = "n", conceallevel = 3 },
                },
            },

            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = false, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = true, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
        },
        config = function(_, opts)
            require("noice").setup(opts)
            vim.keymap.set("n", "<leader>m", function()
                require("noice").cmd("history")
            end, { desc = "Notifications history" })
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            npairs.setup({})

            npairs.add_rules({
                Rule("<", ">", { "rust" }),
            })
            npairs.add_rules({
                Rule('<<"', '">>', { "erlang", "elixir" }),
            })
        end,
    },
    {
        "kylechui/nvim-surround",
        opts = {},
    },
    {
        "folke/todo-comments.nvim",
        config = function()
            require("todo-comments").setup({
                keywords = {
                    XXX = {
                        icon = " ",
                        color = "error",
                    },
                    TODO = {
                        icon = " ",
                        color = "info",
                        alt = { "todo" },
                    },
                },
                highlight = {
                    pattern = [[.*<(KEYWORDS)\s*]],
                },
                search = {
                    pattern = [[\b(KEYWORDS)\b]], -- ripgrep regex
                },
            })
            vim.keymap.set("n", "<leader>t", "<cmd>TodoTrouble<enter>", { silent = true, desc = "Show TODOs in Trouble list" })
        end,
    },
    {
        "smjonas/inc-rename.nvim",
        opts = {},
    },
    {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts)
            require("ts-comments").setup(opts)
            vim.keymap.set("n", "<leader>c<leader>", "gcc", { remap = true, desc = "Toggle comment line" })
            vim.keymap.set("n", "<leader>B<leader>", "gbc", { remap = true, desc = "Toggle comment block" })
            vim.keymap.set({ "x", "o" }, "<leader>c", "gc", { remap = true, desc = "Comment line" })
            vim.keymap.set({ "x", "o" }, "<leader>B", "gb", { remap = true, desc = "Comment block" })
            vim.keymap.set("n", "<leader>cO", "gcO", { remap = true, desc = "Comment above" })
            vim.keymap.set("n", "<leader>co", "gco", { remap = true, desc = "Comment below" })
            vim.keymap.set("n", "<leader>cA", "gcA", { remap = true, desc = "Comment end of line" })
        end,
    },
    {
        "kevinhwang91/nvim-ufo",
        enabled = false,
        dependencies = { "kevinhwang91/promise-async" },
        opts = {
            provider_selector = function(bufnr, filetype)
                return { "treesitter", "indent" }
            end,
        },
        config = function(_, opts)
            local ufo = require("ufo")

            vim.o.foldcolumn = "1" -- '0' is not bad
            vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            vim.keymap.set("n", "zR", function()
                ufo.openAllFolds()
            end, { desc = "Open all folds" })
            vim.keymap.set("n", "zM", function()
                ufo.closeAllFolds()
            end, { desc = "Close all folds" })

            require("ufo").setup(opts)
        end,
    },
    {
        "tzachar/local-highlight.nvim",
        opts = {},
    },
    {
        "denialofsandwich/sudo.nvim",
        opts = {},
        lazy = true,
        cmd = { "SudoRead", "SudoWrite" },
    },
    {
        "ovk/endec.nvim",
        opts = {},
    },
}
