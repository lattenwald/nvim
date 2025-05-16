return {
    {
        "saghen/blink.cmp",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "Kaiser-Yang/blink-cmp-avante",
            "fang2hou/blink-copilot",
        },

        init = function()
            CmpEngine = {
                BLINK = 1,
                NVIM_CMP = 2,
            }
            vim.g.cmp_engine = CmpEngine.BLINK
            vim.api.nvim_create_user_command("ToggleCmpEngine", function()
                if vim.g.cmp_engine == CmpEngine.BLINK then
                    vim.g.cmp_engine = CmpEngine.NVIM_CMP
                    vim.notify("Completion engine is now nvim-cmp")
                else
                    vim.g.cmp_engine = CmpEngine.BLINK
                    vim.notify("Completion engine is now blink.cmp")
                end
            end, { desc = "Switch completion engine" })
        end,

        -- use a release tag to download pre-built binaries
        version = "*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            enabled = function()
                return not require("config.utils").is_plugin_installed("nvim.cmp") or vim.g.cmp_engine == CmpEngine.BLINK
            end,
            -- stylua: ignore
            keymap = {
                preset = "none",
                ["<up>"] = { 'select_prev', 'fallback' },
                ["<down>"] = { 'select_next', 'fallback' },
                ["<tab>"] = { 'accept', 'fallback' },
                ["<c-enter>"] = { 'select_and_accept', 'fallback' },
                ["<leader>cD"] = { 'show_documentation' },
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
        config = function(_, opts)
            require("blink.cmp").setup(opts)
            vim.api.nvim_set_keymap("i", "<Esc>", 'pumvisible() ? "<C-e><Esc>" : "<Esc>"', { expr = true })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        enabled = false,
        version = nil,
        event = "InsertEnter",
        lazy = false,
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
                dependencies = { "rafamadriz/friendly-snippets" },
            },
            {
                "zbirenbaum/copilot-cmp",
                config = function()
                    require("copilot_cmp").setup()
                end,
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
        config = function()
            if require("config.utils").is_plugin_installed("nvim-autopairs") then
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                local cmp = require("cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end

            local lspconfig = require("lspconfig")
            local lsp_defaults = lspconfig.util.default_config

            -- Merge default capabilities with nvim-cmp enhancements
            lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

            local cmp = require("cmp")

            cmp.setup({
                enabled = function()
                    return not require("config.utils").is_plugin_installed("blink-cmp") or vim.g.cmp_engine == CmpEngine.NVIM_CMP
                end,
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

            -- `/` cmdline setup.
            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            -- `:` cmdline setup.
            -- cmp.setup.cmdline(":", {
            --     mapping = {
            --         ["<up>"] = cmp.mapping.select_prev_item(),
            --         ["<down>"] = cmp.mapping.select_next_item(),
            --         ["<tab>"] = cmp.mapping.confirm({select = true}),
            --         ["<c-enter>"] = cmp.mapping.confirm({ select = true }),
            --         -- ["<s-space>"] = cmp.mapping.preset,
            --         ["<esc>"] = cmp.abort(),
            --     },
            --     sources = cmp.config.sources({
            --         { name = "path" },
            --         { name = "cmdline" },
            --     }, {
            --         {
            --             name = "cmdline",
            --             option = {
            --                 ignore_cmds = { "Man", "!" },
            --             },
            --         },
            --     }),
            -- })

            vim.api.nvim_create_autocmd({ "CursorHoldI", "TextChangedI" }, {
                callback = cmp.complete,
            })
        end,
    },
}
