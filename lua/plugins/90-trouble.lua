return {
    {
        'folke/trouble.nvim',
        event = 'VeryLazy',
        config = function()
            require'trouble'.setup{}
            vim.api.nvim_set_keymap('n', '<leader>q', ':TroubleToggle document_diagnostics<cr>', {silent = true, desc = 'Toggle trouble list'})
        end
    }
}
