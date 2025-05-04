return {
    {
        "vhyrro/luarocks.nvim",
        enabled = false,
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
        opts = {
            rocks = { "xml2lua", "mimetypes" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "markdown",
                "markdown_inline",
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                disable = {
                    "latex",
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-treesitter.configs").setup({
                autotag = {
                    enable = true,
                },
            })
        end,
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
                "<leader>-",
                "<cmd>Yazi<enter>",
                desc = "Open yazi at the current file",
            },
            {
                "<leader>z",
                "<cmd>Yazi<enter>",
                desc = "Open yazi at the current file",
            },
            {
                -- Open in the current working directory
                "<leader>cw",
                "<cmd>Yazi cwd<enter>",
                desc = "Open the file manager in nvim's working directory",
            },
            {
                -- NOTE: this requires a version of yazi that includes
                -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
                "<c-up>",
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
        "albenisolmos/autochdir.nvim",
        opts = {
            keep_dir = false,
            flags = {
                ["rs"] = { "Cargo.toml" },
                ["c"] = { "Makefile", "CMake" },
                ["py"] = { "pyproject.toml", "requirements.txt" },
            },

            -- Define generic flags for all files
            generic_flags = { "README.md", ".git" },
        },
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
        "lewis6991/gitsigns.nvim",
        opts = {},
        config = function(_, opts)
            require("gitsigns").setup(opts)

            -- Setup keymaps
            vim.keymap.set("n", "hs", '<cmd>lua require"gitsigns".stage_hunk()<enter>', { desc = "Stage hunk" })
            vim.keymap.set("n", "<leader>hp", '<cmd>lua require"gitsigns".preview_hunk()<enter>', { desc = "Preview hunk" })
            vim.keymap.set("n", "<leader>hr", '<cmd>lua require"gitsigns".reset_hunk()<enter>', { desc = "Reset hunk" })
            vim.keymap.set("n", "<leader>hS", '<cmd>lua require"gitsigns".stagefer()<enter>', { desc = "Stage buffer" })
            vim.keymap.set("n", "<leader>hu", '<cmd>lua require"gitsigns".undo_stage_hunk()<enter>', { desc = "Undo stage hunk" })
            vim.keymap.set("n", "]c", '<cmd>lua require"gitsigns".next_hunk()<enter>', { desc = "Next hunk" })
            vim.keymap.set("n", "[c", '<cmd>lua require"gitsigns".prev_hunk()<enter>', { desc = "Next hunk" })
        end,
    },
    {
        "kevinhwang91/nvim-ufo",
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
        "AckslD/messages.nvim",
        opts = {},
    },
    {
        "tzachar/local-highlight.nvim",
        opts = {},
    },
}
