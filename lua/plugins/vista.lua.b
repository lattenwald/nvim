return {
    {
        'liuchengxu/vista.vim',
        config = function()
            vim.g.vista_icon_indent = {"|_ ", "|- "}
            vim.g.vista_fold_toggle_icons = {'v', '>'}
            vim.g.vista_default_executive = 'ctags'
            vim.g.vista_executive_for = {
                ["erl"] = 'coc',
                ["js"] = 'coc',
                ["ex"] = 'coc',
                ["vimwiki"] = 'markdown',
                ["md"] = 'markdown',
                ["markdown"] = 'toc',
            }

            vim.api.nvim_set_keymap('n', '<leader>v', ':Vista ctags<cr>', {desc = 'Vista ctags'})
            vim.api.nvim_set_keymap('n', '<leader>V', ':Vista coc<cr>', {desc = 'Vista coc'})
            -- TODO
            -- nnoremap <leader>i :Vista finder fzf:ctags<Return>
            -- nnoremap <leader>I :Vista finder fzf:coc<Return>
            vim.g.vista_sidebar_position = 'vertical topleft'
        end
    }
}
