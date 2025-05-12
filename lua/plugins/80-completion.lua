return {
    {
        "saghen/blink.cmp",
        enabled = false,
        dependencies = {
            "rafamadriz/friendly-snippets",
            "Kaiser-Yang/blink-cmp-avante",
            "fang2hou/blink-copilot",
        },

        -- use a release tag to download pre-built binaries
        version = "*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- stylua: ignore
            keymap = {
                preset = "none",
                ["<up>"] = { 'select_prev', 'fallback' },
                ["<down>"] = { 'select_next', 'fallback'  },
                ["<tab>"] = { 'select_and_accept', 'fallback'  },
                ["<c-enter>"] = { 'select_and_accept', 'fallback'  },
                ["<s-space>"] = { 'show_and_insert', 'fallback'  },
                ["<esc>"] = { 'hide', 'fallback' },
                ["<leader>cD"] = { 'show_documentation' },
            },

            cmdline = {
                completion = { menu = { auto_show = true } },
                keymap = {
                    preset = "none",
                    ["<up>"] = { "select_prev" },
                    ["<down>"] = { "select_next" },
                    ["<tab>"] = { "show", "select_and_accept" },
                    ["<s-space>"] = { "show_and_insert" },
                    ["<esc>"] = { "hide", "fallback" },
                },
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 500 },
                ghost_text = { enabled = true },
            },

            sources = {
                default = { "avante", "copilot", "lsp", "path", "snippets", "buffer" },
                providers = {
                    avante = {
                        module = "blink-cmp-avante",
                        name = "Avante",
                        opts = {
                            -- options for blink-cmp-avante
                        },
                    },
                    copilot = {
                        name = "copilot",
                        module = "blink-copilot",
                        score_offset = 100,
                        async = true,
                    },
                },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
    {
        "hrsh7th/nvim-cmp",
        version = nil,
        event = "InsertEnter",
        lazy = false,
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
                dependencies = { "rafamadriz/friendly-snippets" },
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                sources = require("cmp").config.sources({
                    { name = "copilot" },
                    { name = "nvim_lsp" },
                    { name = "cmp_r" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "buffer" },
                }),
                mapping = {
                    ["<up>"] = cmp.mapping.select_prev_item(),
                    ["<down>"] = cmp.mapping.select_next_item(),
                    ["<tab>"] = cmp.mapping.confirm({ select = true }),
                    ["<c-enter>"] = cmp.mapping.confirm({ select = true }),
                    ["<enter>"] = cmp.mapping.confirm(),
                    ["<esc>"] = function()
                        cmp.abort()
                        vim.cmd("stopinsert")
                    end,
                },
            })

            vim.api.nvim_create_autocmd({ "CursorHoldI", "TextChangedI" }, {
                callback = cmp.complete,
            })
        end,
    },
}
