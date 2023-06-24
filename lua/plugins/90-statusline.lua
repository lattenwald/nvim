return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'linrongbin16/lsp-progress.nvim',
        },
        config = function()
            local lualine = require'lualine'
            local lsp_progress = require'lsp-progress'
            lsp_progress.setup{
                event = 'LspProgressUpdate',
            }

            local git_repo = function()
                local git_dir = vim.fs.find('.git', {
                    upward = true,
                    stop = vim.loop.os_homedir(),
                    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                })[1]
                local repo_dir = vim.fs.dirname(git_dir)
                return vim.fs.basename(repo_dir)
            end

            local opts = {
                theme = 'auto',
                sections = {
                    lualine_b = {git_repo, 'branch', 'diff', 'diagnostics'},
                    lualine_c = {'filename', lsp_progress.progress},
                }
            }

            lualine.setup(opts)

            vim.api.nvim_create_autocmd('User', {
                group = 'lualine',
                pattern = 'LspProgressUpdate',
                desc = 'Update statusline on LSP progress update',
                callback = lualine.refresh,
            })
        end,
    },
}
