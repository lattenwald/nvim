return {
    {
        'nvim-telescope/telescope.nvim',
        event = 'VeryLazy',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'debugloop/telescope-undo.nvim',
        },
        config = function()
            local telescope = require'telescope';
            telescope.setup({
                    extensions = {
                        undo = {}
                    }
                })
            telescope.load_extension('undo')

            vim.api.nvim_set_keymap('n', '<leader>i', ':Telescope lsp_document_symbols<cr>', {desc = 'LSP jump to document symbol'})
            vim.api.nvim_set_keymap('n', 'gr', ':Telescope lsp_references<cr>', {desc = 'LSP jump to reference'})
            vim.api.nvim_set_keymap('n', 'gd', ':Telescope lsp_definitions<cr>', {desc = 'LSP jump to definition'})

            vim.api.nvim_set_keymap('n', '<leader>b', ':Telescope buffers<cr>', {desc = 'Jump to buffers'})
            vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope git_files<cr>', {desc = 'Jump to file tracked by git'})
            vim.api.nvim_set_keymap('n', '<leader>c', ':Telescope git_commits<cr>', {desc = 'Jump to git commit'})
        end
    },
}
