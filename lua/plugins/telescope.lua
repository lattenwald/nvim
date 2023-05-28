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
            vim.keymap.set('n', '<leader>i', builtin.lsp_document_symbols, {desc = 'LSP jump to document symbol'})
            vim.keymap.set('n', 'gr', builtin.lsp_references, {desc = 'LSP jump to reference'})
            vim.keymap.set('n', 'gd', function() require'telescope.builtin'.lsp_definitions{jump_type = "tab"} end, {desc = 'LSP jump to definition'})

            vim.keymap.set('n', '<leader>I', builtin.treesitter, {desc = 'LSP jump to treesitter symbol'})

            vim.keymap.set('n', '<leader>b', function()
                require'telescope.builtin'.buffers{
                    sort_lastused = true,
                    sort_mru = true,
                }
            end, {desc = 'Jump to buffers'})

            vim.keymap.set('n', '<leader>f', builtin.git_files, {desc = 'Jump to file tracked by git'})
            vim.keymap.set('n', '<leader>c', builtin.git_commits, {desc = 'Jump to git commit'})
            vim.keymap.set('n', '<leader>r', builtin.live_grep, {desc = 'Live grep with rg'})

            vim.keymap.set('n', '<leader>u', "<cmd>Telescope undo<cr>", {desc = 'undo tree'})
        end
    },
}
