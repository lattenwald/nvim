return {
    {
        'nvim-telescope/telescope.nvim',
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
                    },
                    defaults = {
                        mappings = {
                            i = {
                                ["<c-cr>"] = "select_tab",
                                ["<esc>"] = "close",
                            },
                            n = {
                                ["<c-cr>"] = "select_tab",
                                ["<esc>"] = "close",
                            },
                        },
                    },
                    pickers = {
                        buffers = {
                            mappings = {
                                i = {
                                    ["<delete>"] = "delete_buffer"
                                },
                                n = {
                                    ["<delete>"] = "delete_buffer"
                                },

                            }
                        }
                    }
                })

            local builtin = require'telescope.builtin'

            vim.keymap.set('n', '<leader>i', function()
                if require'util'.lsp_active() then
                    builtin.lsp_document_symbols()
                else
                    builtin.treesitter()
                end
            end, {desc = 'Jump to document symbol'})
            vim.keymap.set('n', '<leader>I', builtin.treesitter, {desc = 'Jump to treesitter symbol'})

            vim.keymap.set('n', '<leader>b', function()
                require'telescope.builtin'.buffers{
                    sort_lastused = true,
                    sort_mru = true,
                }
            end, {desc = 'Jump to buffers'})

            vim.keymap.set('n', '<leader>f', builtin.git_files, {desc = 'Jump to file tracked by git'})
            vim.keymap.set('n', '<leader>F', builtin.find_files, {desc = 'Jump to file'})
            vim.keymap.set('n', '<leader>c', builtin.git_commits, {desc = 'Jump to git commit'})
            vim.keymap.set('n', '<leader>r', builtin.live_grep, {desc = 'Live grep with rg'})

            vim.keymap.set('n', '<leader>u', "<cmd>Telescope undo<cr>", {desc = 'undo tree'})
        end
    },
}
