return {
    {
        'folke/trouble.nvim',
        config = function()
            local trouble = require'trouble'
            trouble.setup{}
            vim.keymap.set('n', '<leader>q', function() trouble.toggle('document_diagnostics') end, {silent = true, desc = 'Toggle trouble in document diagnostics mode'})
        end
    }
}
