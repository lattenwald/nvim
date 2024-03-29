return {
    {
        'NeogitOrg/neogit',
        enabled = false,
        opts = {},
    },
    {
        "airblade/vim-gitgutter",
    },
    {
        "itchyny/vim-gitbranch",
    },
    {
        "tpope/vim-fugitive",
    },
    {
        'sindrets/diffview.nvim',
        opts = {},
    },
    {
        'kdheepak/lazygit.nvim',
        dependencies = {'nvim-lua/plenary.nvim'},
        config = function()
            vim.g.lazygit_floating_window_use_plenary = 1
            require("telescope").load_extension("lazygit")
            vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', {desc = "LazyGit"})
        end,
    }
}
