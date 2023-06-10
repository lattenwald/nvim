return {
    {
        'folke/trouble.nvim',
        config = function()
            local trouble = require'trouble'
            trouble.setup{}
            vim.keymap.set('n', '<leader>q', trouble.toggle, {silent = true, desc = 'Toggle trouble list'})
        end
    }
}
