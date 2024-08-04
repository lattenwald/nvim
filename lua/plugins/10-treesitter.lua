return {
    {
        'nvim-treesitter/nvim-treesitter',
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
                "markdown",
                "markdown_inline",
                "regex",
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
            require'nvim-treesitter.configs'.setup(opts)
        end,
    }
}
