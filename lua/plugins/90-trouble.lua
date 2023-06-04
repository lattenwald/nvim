return {
    {
        'folke/trouble.nvim',
        config = function()
            require'trouble'.setup{}
            vim.api.nvim_set_keymap('n', '<leader>q', ':TroubleToggle document_diagnostics<cr>', {silent = true, desc = 'Toggle trouble list'})
        end
    }
}
