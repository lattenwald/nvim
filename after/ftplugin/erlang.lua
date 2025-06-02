require("config.utils").mason_install("erlang-ls")

local dap = require("dap")

dap.adapters.erlang = {
    type = "executable",
    command = "els_dap",
    args = {},
}

-- Debug configurations
dap.configurations.erlang = {
    {
        type = "erlang",
        request = "launch",
        name = "Launch Erlang Node",
        cwd = "${workspaceFolder}",
        program = function()
            return vim.fn.input("Path to script: ", vim.fn.expand("%"), "file")
        end,
        cookie = function()
            return vim.fn.input("Erlang cookie: ", "secret")
        end,
        runtimeArgs = { "-sname", "debug_node" },
    },
    {
        type = "erlang",
        request = "attach",
        name = "Attach to Running Node",
        node = "debug_node@localhost",
        cookie = function()
            return vim.fn.input("Erlang cookie: ", "secret")
        end,
    },
}
