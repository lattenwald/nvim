require("config.utils").mason_install("bash-language-server")
require("config.utils").mason_install("beautysh")
require("conform").setup({
    formatters_by_ft = {
        sh = { "beautysh" },
    },
})
require("config.utils").mason_install("bash-debug-adapter")

local dap = require("dap")

dap.adapters.sh = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
    args = {},
}

dap.configurations.sh = {
    {
        type = "sh",
        request = "launch",
        name = "Debug Bash Script",
        program = "${file}",
        cwd = "${fileDirname}",
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        env = {
            SHELL = "/bin/bash",
        },
    },
}
