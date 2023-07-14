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
            vim.keymap.set('n', '<leader>V', '<cmd>AerialToggle<cr>', {desc = "Toggle code outline"})
        end
    },
    {
        'simrat39/symbols-outline.nvim',
        opts = {},
    },
    {
        'Bekaboo/dropbar.nvim',
        enabled = false,
        opts = {},
    }
}
