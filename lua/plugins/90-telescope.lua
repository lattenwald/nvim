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
                                ["<c-c>"] = "close",
                            },
                            n = {
                                ["<c-cr>"] = "select_tab",
                                ["<esc>"] = "close",
                                ["q"] = "close",
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

            local project_dir = function()
                local git_dir = vim.fs.find('.git', {
                    upward = true,
                    stop = vim.loop.os_homedir(),
                    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                })[1]
                return vim.fs.dirname(git_dir)
            end

            vim.keymap.set('n', '<leader>f', builtin.git_files, {desc = 'Jump to file tracked by git'})
            vim.keymap.set('n', '<leader> f', function() builtin.find_files{cwd = project_dir()} end, {desc = 'Jump to file'})
            vim.keymap.set('n', '<leader>c', builtin.git_commits, {desc = 'Jump to git commit'})
            vim.keymap.set('n', '<leader>r', function() builtin.live_grep{cwd = project_dir()} end, {desc = 'Live grep with rg'})

            vim.keymap.set('n', '<leader>u', "<cmd>Telescope undo<cr>", {desc = 'undo tree'})
        end
    },
    {
        'nvim-telescope/telescope-file-browser.nvim',
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            require'telescope'.load_extension'file_browser'
        end,
    },
    {
        'nvim-telescope/telescope-project.nvim',
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
        config = function()
            require'telescope'.load_extension'project'
            vim.keymap.set('n', '<leader>p', require'telescope'.extensions.project.project, {desc = 'Projects'})
        end,
    }
}
