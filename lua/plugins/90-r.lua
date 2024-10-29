return {
    {
        -- https://github.com/jamespeapen/Nvim-R/wiki/Use
        -- to start: \rf in .R file
        'R-nvim/R.nvim',
        lazy = false,
        enabled = function()
            vim.fn.executable("r")
        end,
    },
    {
        'R-nvim/cmp-r',
        opts = {},
        enabled = function()
            vim.fn.executable("r")
        end,
    }
}
