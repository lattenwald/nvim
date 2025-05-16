vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

require("config.utils").mason_install("typescript-language-server")
require("config.utils").mason_install("eslint-lsp")
require("config.utils").mason_install("prettierd")
require("conform").setup({
    formatters_by_ft = {
        javascript = { "prettierd" },
    },
})
