return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        opts = {
            sync_root_with_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            }
        },
        config = function(_, opts)
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            require'nvim-tree'.setup(opts)

            vim.keymap.set('n', '<C-f>', '<cmd>NvimTreeToggle<cr>', {desc = "NvimTree toggle"})
        end,
    }
}
