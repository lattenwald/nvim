return {
    {
        "sainnhe/sonokai",
        lazy = false,
        config = function()
            vim.g.sonokai_disable_italic_comment = 1
            vim.g.sonokai_style = "default"
            vim.cmd("colorscheme sonokai")
        end,
    },
    {
        "marko-cerovac/material.nvim",
        lazy = true,
        config = function()
            require("material.functions").change_style("darker")

            function ColorschemeMaterialWithStyle()
                vim.cmd("colorscheme material")
                require("material.functions").find_style()
            end

            vim.api.nvim_create_user_command("MaterialWithStyle", ColorschemeMaterialWithStyle, {})
        end,
    },
    {
        "mhartington/oceanic-next",
    },
    {
        "folke/tokyonight.nvim",
    },
    {
        "nvimdev/zephyr-nvim",
    },
    {
        "vim-scripts/wombat256.vim",
    },
    {
        "ViViDboarder/wombat.nvim",
        dependencies = { "rktjmp/lush.nvim" },
    },
    {
        "sainnhe/everforest",
    },
    {
        "sainnhe/edge",
    },
}
