return {
    {
        -- https://github.com/jamespeapen/Nvim-R/wiki/Use
        -- to start: \rf in .R file
        "R-nvim/R.nvim",
        lazy = false,
        enabled = function()
            return vim.fn.executable("R") == 1
        end,
    },
    {
        "R-nvim/cmp-r",
        opts = {},
        enabled = function()
            return vim.fn.executable("R") == 1
        end,
    },
}
