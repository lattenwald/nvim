require'nvim-surround'.buffer_setup {
    surrounds = {
        ["q"] = {
            add = function()
                return {{'<<"'}, {'">>'}}
            end,
            find = function()
                return config.get_selection({
                        pattern = '<<".-">>'
                    })
            end,
            -- TODO fix
            delete = '(<<")().-(">>)()',
            change = {
                target = '^(<<")().-(">>)()$',
            }
        }
    }
}
