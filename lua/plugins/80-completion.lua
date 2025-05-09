return {
    {
        "saghen/blink.cmp",
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
}
