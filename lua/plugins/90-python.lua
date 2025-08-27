return {
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require("dap-python").setup("uv")
        end,
    },
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap",
            "mfussenegger/nvim-dap-python", --optional
        },
        lazy = false,
        opts = {
            picker = {
                type = "snacks", -- Custom type name, just to indicate we override
                -- The function Snacks will call to pick
                fn = function(opts, on_choice)
                    -- opts.items is the list of venvs discovered
                    local items = {}
                    for _, venv in ipairs(opts.items) do
                        table.insert(items, {
                            text = venv.name,
                            path = venv.path,
                        })
                    end

                    -- Use Snacks picker
                    require("snacks").picker({
                        prompt = "Select Python venv",
                        items = items,
                        format_item = function(item)
                            return item.text
                        end,
                        on_select = function(item)
                            on_choice(item.path) -- Send selected venv path back to venv-selector
                        end,
                    })
                end,
            },
        },
    },
}
