return {
    {
        "windwp/nvim-autopairs",
        event = 'InsertEnter',
        config = function()
            local npairs = require('nvim-autopairs')
            local Rule = require('nvim-autopairs.rule')
            npairs.setup{}

            npairs.add_rules{
                Rule('<', '>', {'rust'})
            }
            npairs.add_rules{
                Rule('<<"', '">>', {'erlang', 'elixir'})
            }
        end,
    },
    {
        "kylechui/nvim-surround",
        opts = {},
    },
    {
        'windwp/nvim-ts-autotag',
        config = function()
            require'nvim-treesitter.configs'.setup {
                autotag = {
                    enable = true,
                }
            }
        end
    }
}
