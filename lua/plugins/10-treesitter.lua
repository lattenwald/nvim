return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "rust",
                "erlang",
                "elixir",
                "heex",
                "perl",
                "bash",
                "lua",
                "dockerfile",
                "gitignore",
                "vim",
                "json5",
                "html",
                "yaml",
                "markdown",
                "markdown_inline",
                "regex",
                "r",
                "rnoweb",
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                disable = {
                    "latex",
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-treesitter.configs").setup({
                autotag = {
                    enable = true,
                },
            })
        end,
    },
}
