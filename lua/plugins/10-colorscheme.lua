return {
    {
        'sainnhe/sonokai',
        lazy = false,
        config = function()
            vim.g.sonokai_disable_italic_comment = 1
            vim.g.sonokai_style = 'default'
            vim.cmd'colorscheme sonokai'
        end
    },
    {
        "marko-cerovac/material.nvim",
        lazy = true,
        config = function()
            require'material.functions'.change_style("darker")

            ColorschemeMaterialWithStyle = function()
                vim.cmd'colorscheme material'
                require'material.functions'.find_style()
            end

            vim.api.nvim_create_user_command('MaterialWithStyle', ColorschemeMaterialWithStyle, {})
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
    },
    {
        'sainnhe/everforest',
        lazy = true
    },
    {
        'sainnhe/edge',
        lazy = true,
    },

}
