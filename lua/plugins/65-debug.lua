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
        config = function()
            local dap = require("dap")
            local widgets = require("dap.ui.widgets")

            -- Common keymaps
            vim.keymap.set("n", "<C-F5>", function()
                require("dapui").toggle()
            end, { desc = "Debug: Show UI" })
            vim.keymap.set("n", "<F5>", function()
                dap.continue()
            end, { desc = "Debug: Continue" })
            vim.keymap.set("n", "<F8>", function()
                dap.toggle_breakpoint()
            end, { desc = "Debug: Toggle breakpoint" })

            -- Keymaps only when DAP is active
            -- stylua: ignore
            local keymaps = {
                {"<F10>", "n", function() dap.step_over() end, {desc = "Debug: Step over"}},
                {"<F11>", "n", function() dap.step_into() end, {desc = "Debug: Step into"}},
                {"<F12>", "n", function() dap.step_out() end, {desc = "Debug: Step out"}},
                {"<Leader>lb", "n", function() dap.toggle_breakpoint() end, {desc = "Debug: Toggle breakpoint"}},
                {"<Leader>lB", "n", function() dap.set_breakpoint() end, {desc = "debug: Set breakpoint"}},
                {"<Leader>lp", "n", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, {desc = "Debug: Set log point"}},
                {"<Leader>lr", "n", function() dap.repl.open() end, {desc = "Debug: Open REPL"}},
                {"<Leader>ll", "n", function() dap.run_last() end, {desc = "Debug: Run last"}},

                {"<Leader>lh", {"n", "v"}, function() widgets.hover() end, {desc = "Debug: Hover"}},
                {"<Leader>lp", {"n", "v"}, function() widgets.preview() end, {desc = "Debug: Preview"}},
                {"<Leader>lf", "n", function() widgets.centered_float(widgets.frames) end, {desc = "Debug: Frames"}},
                {"<Leader>ls", "n", function() widgets.centered_float(widgets.scopes) end, {desc = "Debug: Scopes"}},
            }

            -- Set keymaps when DAP is initialized
            dap.listeners.after.event_initialized["custom.dap.keys"] = function()
                for _, map in ipairs(keymaps) do
                    local key, modes, func, opts = unpack(map)
                    vim.keymap.set(modes, key, func, opts)
                end
            end

            -- Remove keymaps when DAP is terminated or disconnected
            local reset_keys = function()
                for _, map in ipairs(keymaps) do
                    local key, modes = unpack(map)
                    pcall(vim.keymap.del, modes, key)
                end
            end
            dap.listeners.after.event_terminated["me.dap.keys"] = reset_keys
            dap.listeners.after.disconnected["me.dap.keys"] = reset_keys
        end,
    },
}
