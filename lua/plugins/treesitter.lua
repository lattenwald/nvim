return {
    {
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = {
                    "rust",
                    "erlang",
                    "elixir",
                    "perl",
                    "bash",
                    "lua",
                    "dockerfile",
                    "gitignore",
                    "vim",
                    "json5",
                    "html",
                },
                sync_install = false,
                auto_install = true,
            }
        end
    }
}
