return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
            "nvim-telescope/telescope-dap.nvim",
            "jbyuki/one-small-step-for-vimkind", -- LUA DAP adapter
            "nvim-neotest/nvim-nio",
            -- 'ldelossa/nvim-dap-projects',
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local dap_ui_widgets = require("dap.ui.widgets")

            dap.adapters.lldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "/usr/bin/lldb-dap",
                },
            }

            dapui.setup({})
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP continue" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP step over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP step into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP step out" })
            vim.keymap.set("n", "<Leader>eb", dap.toggle_breakpoint, { desc = "DAP toggle breakpoint" })
            vim.keymap.set("n", "<Leader>eB", dap.set_breakpoint, { desc = "DAP set breakpoint" })
            vim.keymap.set("n", "<Leader>el", function()
                dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end, { desc = "DAP set log breakpoint" })
            vim.keymap.set("n", "<Leader>er", dap.repl.open, { desc = "DAP open repl" })
            vim.keymap.set("n", "<Leader>el", dap.run_last, { desc = "DAP run last" })
            vim.keymap.set({ "n", "v" }, "<Leader>eh", dap_ui_widgets.hover, { desc = "DAP UI hover" })
            vim.keymap.set({ "n", "v" }, "<Leader>ep", dap_ui_widgets.preview, { desc = "DAP preview" })
            vim.keymap.set("n", "<Leader>ef", function()
                dap_ui_widgets.centered_float(dap_ui_widgets.frames)
            end, { desc = "DAP UI frames" })
            vim.keymap.set("n", "<Leader>es", function()
                dap_ui_widgets.centered_float(dap_ui_widgets.scopes)
            end, { desc = "DAP UI scopes" })
        end,
    },
}
