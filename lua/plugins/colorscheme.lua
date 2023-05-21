return {
    {
        "marko-cerovac/material.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd'colorscheme material'
            require'material.functions'.change_style("darker")
        end
    },
    {
        "mhartington/oceanic-next",
        lazy = true,
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
    },
    {
        "nvimdev/zephyr-nvim",
        lazy = true,
    },
    {
        'vim-scripts/wombat256.vim',
        lazy = true,
    },
    {
        'ViViDboarder/wombat.nvim',
        lazy = true,
        dependencies = {'rktjmp/lush.nvim'},
    }
}
