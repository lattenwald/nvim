return {
    {

        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
    },
    {
        "saghen/blink.cmp",

        -- use a release tag to download pre-built binaries
        version = "*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            snippets = { preset = "luasnip" },
            -- stylua: ignore
            keymap = {
                preset = "none",
                ["<up>"] = { 'select_prev', 'fallback' },
                ["<down>"] = { 'select_next', 'fallback' },
                ["<tab>"] = { 'accept', 'fallback' },
                ["<c-enter>"] = { 'select_and_accept', 'fallback' },
                ["<c-h>"] = { 'show_documentation' },
            },

            cmdline = {
                enabled = true,
                completion = { menu = { auto_show = true } },
                keymap = {
                    preset = "none",
                    ["<up>"] = { "select_prev" },
                    ["<down>"] = { "select_next" },
                    ["<tab>"] = { "show", "select_and_accept" },
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
                default = { "lsp", "path", "snippets", "buffer" },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
        config = function(_, opts)
            require("blink.cmp").setup(opts)
            vim.api.nvim_set_keymap("i", "<Esc>", 'pumvisible() ? "<C-e><Esc>" : "<Esc>"', { expr = true })
        end,
    },
}
