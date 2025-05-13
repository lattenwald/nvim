return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                "rcarriga/nvim-dap-ui",
                dependencies = {
                    "nvim-neotest/nvim-nio",
                },
                opts = {
                    automatic_setup = true,
                },
            },

            "mason-org/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
        -- stylua: ignore
        config = function()
            vim.keymap.set('n', '<C-F5>', function() require('dapui').toggle() end)
            vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
            vim.keymap.set('n', '<F8>', function() require('dap').toggle_breakpoint() end)
            vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
            vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
            vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
            vim.keymap.set('n', '<Leader>lb', function() require('dap').toggle_breakpoint() end)
            vim.keymap.set('n', '<Leader>lB', function() require('dap').toggle_breakpoint() end)
            vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
            vim.keymap.set('n', '<Leader>lr', function() require('dap').repl.open() end)
            vim.keymap.set('n', '<Leader>ll', function() require('dap').run_last() end)
            vim.keymap.set({'n', 'v'}, '<Leader>lh', function()
                require('dap.ui.widgets').hover()
            end)
            vim.keymap.set({'n', 'v'}, '<Leader>lp', function()
                require('dap.ui.widgets').preview()
            end)
            vim.keymap.set('n', '<Leader>lf', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.frames)
            end)
            vim.keymap.set('n', '<Leader>ls', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.scopes)
            end)

        end,
    },
}
