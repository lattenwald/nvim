require("config.utils").mason_install("css-lsp")
require("config.utils").mason_install("prettierd")
require("conform").setup({
    formatters_by_ft = {
        css = { "prettierd" },
    },
})
