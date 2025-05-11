return {
    {
        "zbirenbaum/copilot.lua",
        lazy = true,
        cmd = "Copilot",
        opts = {
            suggestion = {
                enabled = false,
                auto_trigger = true,
                keymap = {
                    accept = "<c-enter>",
                },
            },
            panel = {
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
        "yetone/avante.nvim",
        lazy = true,
        cmd = "AvanteToggle",
        version = false, -- Never set this value to "*"! Never!
        opts = {
            provider = "copilot",
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
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
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
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante", "codecompanion" },
                },
                ft = { "markdown", "Avante" },
            },
        },
        config = function(_, opts)
            local avante_opts_file = vim.fn.stdpath("data") .. "/avante_opts.yaml"
            local yaml_opts = require("config.utils").load_yaml(avante_opts_file)
            if yaml_opts then
                opts = vim.tbl_deep_extend("force", opts or {}, yaml_opts or {})
            end
            require("avante").setup(opts)
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        lazy = true,
        cmd = "CodeCompanionActions",
        opts = {},
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
}
