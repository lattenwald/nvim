return {
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function ()
            vim.g.coc_global_extensions = {
                'coc-json',
                'coc-tsserver',
                'coc-yaml',
                'coc-rust-analyzer',
                'coc-elixir',
                'coc-pyright',
                'coc-perl',
                '@yaegassy/coc-ansible',
                'coc-snippets',
            }
            vim.g.coc_filetype_map = { ['yaml.ansible'] = 'ansible' }
            vim.g.coc_disable_transparent_cursor = 1
            vim.api.nvim_set_keymap('n', '[g', '<Plug>(coc-diagnostic-prev)', {silent = true, desc = 'LSP: next diagnostics'})
            vim.api.nvim_set_keymap('n', ']g', '<Plug>(coc-diagnostic-next)', {silent = true, desc = 'LSP: prev diagnostics'})

            vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)', {silent = true, desc = 'LSP: go to definition'})
            vim.api.nvim_set_keymap('n', 'gy', '<Plug>(coc-type-definition)', {silent = true, desc = 'LSP: go to type definition'})
            vim.api.nvim_set_keymap('n', 'gi', '<Plug>(coc-implementation)', {silent = true, desc = 'LSP: go to implementation'})
            vim.api.nvim_set_keymap('n', 'gr', '<Plug>(coc-references)', {silent = true, desc = 'LSP: show references'})

            vim.api.nvim_set_keymap('n', '<leader>rn', '<Plug>(coc-rename)', {silent = true, desc = 'LSP: rename symbol'})

            vim.api.nvim_set_keymap('n', '<leader>f', '<Plug>(coc-format-selected)', {silent = true, desc = 'LSP: format selected'})
            vim.api.nvim_set_keymap('x', '<leader>f', '<Plug>(coc-format-selected)', {silent = true, desc = 'LSP: format selected'})

            vim.api.nvim_set_keymap('n', '<leader>a', '<Plug>(coc-codeaction-selected)', {silent = true, desc = 'LSP: selected codeaction'})
            vim.api.nvim_set_keymap('x', '<leader>a', '<Plug>(coc-codeaction-selected)', {silent = true, desc = 'LSP: selected codeaction'})

            vim.api.nvim_set_keymap('n', '<leader>ac', '<Plug>(coc-codeaction)', {silent = true, desc = 'LSP: codeaction'})
            vim.api.nvim_set_keymap('x', '<leader>ac', '<Plug>(coc-codeaction)', {silent = true, desc = 'LSP: codeaction'})

            vim.api.nvim_set_keymap('n', '<leader>qf', '<Plug>(coc-fix-current)', {silent = true, desc = 'LSP: fix current'})
            vim.api.nvim_set_keymap('n', '<leader>cl', '<Plug>(coc-codelens-action)', {silent = true, desc = 'LSP: codelens-action'})

            -- TODO uncomment or delete
            -- " Map function and class text objects
            -- " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
            -- xmap if <Plug>(coc-funcobj-i)
            -- omap if <Plug>(coc-funcobj-i)
            -- xmap af <Plug>(coc-funcobj-a)
            -- omap af <Plug>(coc-funcobj-a)
            -- xmap ic <Plug>(coc-classobj-i)
            -- omap ic <Plug>(coc-classobj-i)
            -- xmap ac <Plug>(coc-classobj-a)
            -- omap ac <Plug>(coc-classobj-a)

            vim.api.nvim_set_keymap('n', '<C-s>', '<Plug>(coc-range-select)', {silent = true, desc = 'LSP: select range'})
            vim.api.nvim_set_keymap('x', '<C-s>', '<Plug>(coc-range-select)', {silent = true, desc = 'LSP: select range'})

            CheckBackspace = function()
                col = vim.fn.col('.') - 1
                return col > 0 and true or string.match(vim.fn.getline('.')[col - 1], '%s')
            end

            vim.api.nvim_set_keymap('i', '<tab>', [[
                coc#pum#visible() ? coc#_select_confirm() : coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])<cr>" : CheckBackspace() ? "\<tab>" : coc#refresh()
                ]], {expr = true, silent = true})
            vim.api.nvim_set_keymap('i', '<c-cr>', [[coc#pum#visible() ? coc#pub#confirm() : "\<c-cr>"]], {silent = true, expr = true, desc = 'LSP: choose autocompletion'})

            vim.g.coc_snippet_next = '<tab>'

            show_documentation = function ()
                local filetype = vim.bo.filetype
                if filetype == 'vim' or filetype == 'help' then
                    vim.api.nvim_command('h ' .. vim.fn.expand('<cword>'))
                elseif vim.fn.CocAction('hasProvider', 'hover') then
                    vim.fn.CocActionAsync('doHover')
                end
            end
            vim.api.nvim_set_keymap('n', '<leader>d', ':lua show_documentation()<cr>', {desc = 'LSP: show documentation'})

            vim.api.nvim_create_user_command('Format', ':call CocAction("format")', {})
            vim.api.nvim_create_user_command('OR', ':call CocAction("runCommand", "editor.action.organizeImport")', {})

            -- TODO uncomment or delete
            -- command! -nargs=? Fold :call CocAction('fold', <f-args>)
            -- " Mappings for CoCList
            -- " Show all diagnostics.
            -- nnoremap <silent><nowait> ca  :<C-u>CocList diagnostics<cr>
            -- " Manage extensions.
            -- nnoremap <silent><nowait> ce  :<C-u>CocList extensions<cr>
            -- " Show commands.
            -- nnoremap <silent><nowait> cc  :<C-u>CocList commands<cr>
            -- " Find symbol of current document.
            -- nnoremap <silent><nowait> co  :<C-u>CocList outline<cr>
            -- " Search workspace symbols.
            -- nnoremap <silent><nowait> cs  :<C-u>CocList -I symbols<cr>
            -- " Do default action for next item.
            -- nnoremap <silent><nowait> cj  :<C-u>CocNext<CR>
            -- " Do default action for previous item.
            -- nnoremap <silent><nowait> ck  :<C-u>CocPrev<CR>
            -- " Resume latest coc list.
            -- nnoremap <silent><nowait> cp  :<C-u>CocListResume<CR>
        end
    }
}
