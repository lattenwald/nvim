return {
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/vim-vsnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
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
                    {name = 'nvim_lsp'},
                    {name = 'cmp_r'},
                    {name = 'buffer'},
                    {name = 'vsnip'},
                    {name = 'path'},
                },
                mapping = {
                    ['<up>'] = cmp.mapping.select_prev_item(),
                    ['<down>'] = cmp.mapping.select_next_item(),
                    -- ['<esc>'] = cmp.mapping.close(),
                    ['<tab>'] = cmp.mapping.confirm{select = true},
                    ['<cr>'] = cmp.mapping.confirm(),
                    ['<esc>'] = function()
                        cmp.abort()
                        vim.cmd('stopinsert')
                    end,
                },
            }

            vim.api.nvim_create_autocmd({'CursorHoldI', 'TextChangedI'}, {
                callback = cmp.complete
            })
        end
    },
}
