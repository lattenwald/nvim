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
            vim.keymap.set('n', '<C-F5>', function() require('dapui').toggle() end, {desc = "Debug: Show UI"})
            vim.keymap.set('n', '<F5>', function() require('dap').continue() end, {desc = "Debug: Continue"})
            vim.keymap.set('n', '<F8>', function() require('dap').toggle_breakpoint() end, {desc = "Debug: Toggle breakpoint"})
            vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, {desc = "Debug: Step over"})
            vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, {desc = "Debug: Step into"})
            vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, {desc = "Debug: Step out"})
            vim.keymap.set('n', '<Leader>lb', function() require('dap').toggle_breakpoint() end, {desc = "Debug: Toggle breakpoint"})
            vim.keymap.set('n', '<Leader>lB', function() require('dap').set_breakpoint() end, {desc = "debug: Set breakpoint"})
            vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, {desc = "Debug: Set log point"})
            vim.keymap.set('n', '<Leader>lr', function() require('dap').repl.open() end, {desc = "Debug: Open REPL"})
            vim.keymap.set('n', '<Leader>ll', function() require('dap').run_last() end, {desc = "Debug: Run last"})

            vim.keymap.set({'n', 'v'}, '<Leader>lh', function() require('dap.ui.widgets').hover() end, {desc = "Debug: Hover"})
            vim.keymap.set({'n', 'v'}, '<Leader>lp', function() require('dap.ui.widgets').preview() end, {desc = "Debug: Preview"})
            vim.keymap.set('n', '<Leader>lf', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.frames)
            end, {desc = "Debug: Frames"})
            vim.keymap.set('n', '<Leader>ls', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.scopes)
            end, {desc = "Debug: Scopes"})

        end,
    },
}
