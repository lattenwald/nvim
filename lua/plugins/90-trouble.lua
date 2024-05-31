return {
    {
        'folke/trouble.nvim',
        opts = {},
        cmd = 'Trouble',
        keys = {
            {
                '<leader>q',
                '<cmd>Trouble diagnostics filter.buf=0<cr>',
                desc = 'Diagnostics (Trouble)',
            },
            {
                '<leader>V',
                '<cmd>Trouble symbols toggle<cr>',
                desc = 'Symbols (Trouble)',
            },
        }
    }
}
