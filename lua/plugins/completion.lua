return {
    {
        'hrsh7th/nvim-cmp',
        event = 'VeryLazy',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/vim-vsnip',
            'hrsh7th/cmp-buffer',
        },
        config = function()
            local cmp = require'cmp'

            cmp.setup {
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end
                },
                sources = require'cmp'.config.sources{
                    {name = 'buffer'},
                    {name = 'vsnip'},
                    {name = 'nvim_lsp'},
                },
                mapping = {
                    ['<up>'] = cmp.mapping.select_prev_item(),
                    ['<down>'] = cmp.mapping.select_next_item(),
                    ['<C-c>'] = cmp.mapping.close(),
                    ['<esc>'] = cmp.mapping.close(),
                    ['<tab>'] = cmp.mapping.confirm{select = true},
                    ['<cr>'] = cmp.mapping.confirm{select = true},
                },
            }

            vim.api.nvim_create_autocmd({'CursorHoldI', 'TextChangedI'}, {
                callback = cmp.complete
            })
        end
    },
}
