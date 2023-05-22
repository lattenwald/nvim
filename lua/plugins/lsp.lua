return {
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require'lspconfig'
            local lsp_status = require'lsp-status'
            -- TODO incorporate progress and current location in statusline
            lspconfig.erlangls.setup({
                capabilities = lsp_status.capabilities,
                on_attach = lsp_status.on_attach,
            })
            lspconfig.rust_analyzer.setup({
                capabilities = lsp_status.capabilities,
                on_attach = lsp_status.on_attach,
            })
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = {'vim'},
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end
    },
    {
        'simrat39/rust-tools.nvim',
        opts = {},
    },
    {
        'stevearc/aerial.nvim',
        event = "VeryLazy",
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require'aerial'.setup({
                layout = {
                    default_direction = 'prefer_left'
                }
            })
            vim.api.nvim_set_keymap('n', '<leader>v', ':AerialToggle<cr>', {desc = "Toggle LSP outline"})
        end
    },
}
