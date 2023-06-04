return {
    {
        'stevearc/aerial.nvim',
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require'aerial'.setup({
                layout = {
                    default_direction = 'prefer_right',
                },
                backends = {
                    ['_']  = {"lsp", "treesitter", "markdown", "man"},
                    -- vimwiki = {"markdown"},
                },
            })
            vim.api.nvim_set_keymap('n', '<leader>v', ':AerialToggle<cr>', {desc = "Toggle code outline"})
        end
    },
}
