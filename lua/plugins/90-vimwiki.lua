return {
    {
        "vimwiki/vimwiki",
        init = function ()
            vim.g.vimwiki_list = { {
                    path = "/home/qalex/vimwiki/",
                    syntax = "markdown",
                    ext = ".md",
            } }
            vim.g.vimwiki_global_ext = 0
            vim.g.vimwiki_folding = 'list'
            vim.g.vimwiki_key_mappings = { table_mappings = 0, }
            vim.api.nvim_set_keymap('n', '<leader> ', '<Plug>VimwikiToggleListItem', {desc = "VimWiki: toggle list item"})
        end,
    },
    {
        "dkarter/bullets.vim",
    },
    {
        "michal-h21/vimwiki-sync",
    },
}
