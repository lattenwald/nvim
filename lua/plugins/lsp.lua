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
        end
    },
    {
        'simrat39/rust-tools.nvim',
        config = function()
            require'rust-tools'.setup{}
        end
    },
    {
        'stevearc/aerial.nvim',
        opts = {},
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
