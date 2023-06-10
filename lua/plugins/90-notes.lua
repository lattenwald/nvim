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
            vim.keymap.set('n', '<leader><space>', '<Plug>VimwikiToggleListItem', {desc = "VimWiki: toggle list item"})
        end,
    },
    {
        "dkarter/bullets.vim",
    },
    {
        "michal-h21/vimwiki-sync",
    },
    {
        'epwalsh/obsidian.nvim',
        lazy = true,
        event = { "BufReadPre ~/cloud/obsidian/**.md" },
        opts = {
            dir = "~/cloud/obsidian/vault",
            follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart({"xdg-open", url})  -- linux
            end,
        },
        config = function(_, opts)
            require("obsidian").setup(opts)

            -- Optional, override the 'gf' keymap to utilize Obsidian's search functionality.
            vim.keymap.set("n", "gf", function()
                if require("obsidian").util.cursor_on_markdown_link() then
                    return "<cmd>ObsidianFollowLink<CR>"
                else
                    return "gf"
                end
            end, { noremap = false, expr = true })
        end,
    }
}
