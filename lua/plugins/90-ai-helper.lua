return {
    {
        "zbirenbaum/copilot.lua",
        lazy = true,
        cmd = "Copilot",
        opts = {
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = "<c-return>",
                },
            },
        },
    },
    {
        "zbirenbaum/copilot-cmp",
        disabled = true,
        opts = {
            filetypes = {
                yaml = true,
                markdown = true,
            },
            workspace_folder = {
                "/home/qalex/projects/",
                "/home/qalex/kribrum/",
                "/home/qalex/krapiva/",
            },
        },
    },
    {
        "Exafunction/codeium.vim",
        lazy = true,
        cmd = "Codeium",
        config = function()
            vim.g.codeium_no_map_tab = false
            -- Change '<C-g>' here to any keycode you like.
            vim.keymap.set("i", "<c-g>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true, silent = true })
            vim.keymap.set("i", "<c-tab>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true, silent = true })
            vim.keymap.set("i", "<c-return>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true, silent = true })
            vim.keymap.set("i", "<c-;>", function()
                return vim.fn["codeium#CycleCompletions"](1)
            end, { expr = true, silent = true })
            vim.keymap.set("i", "<c-,>", function()
                return vim.fn["codeium#CycleCompletions"](-1)
            end, { expr = true, silent = true })
            vim.keymap.set("i", "<c-x>", function()
                return vim.fn["codeium#Clear"]()
            end, { expr = true, silent = true })
        end,
    },
    {
        "yetone/avante.nvim",
        lazy = true,
        cmd = "AvanteToggle",
        version = false, -- Never set this value to "*"! Never!
        opts = {
            provider = "copilot",
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
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
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
}
