return {
    {
        'neovim/nvim-lspconfig',
        priority = 100,
        config = function()
            local lspconfig = require'lspconfig'
            -- TODO incorporate current location in statusline
            lspconfig.erlangls.setup{}
            lspconfig.rust_analyzer.setup{}
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
    {
        'weilbith/nvim-code-action-menu',
        event = 'VeryLazy',
        cmd = 'CodeActionMenu',
        config = function()
            vim.keymap.set('n', '<leader>a', require'code_action_menu'.open_code_action_menu, {desc = 'LSP code action'})
        end,
    },
    {
        'kosayoda/nvim-lightbulb',
        event = 'VeryLazy',
        opts = {
            autocmd = {enabled = true}
        }
    },
    {
        'j-hui/fidget.nvim',
        opts = {
            text = {
                spinner = 'clock'
            }
        },
    }
}
