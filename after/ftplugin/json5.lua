require("config.utils").mason_install("json-lsp")
require("config.utils").ts_install("json5")
require("config.utils").mason_install("prettierd")
require("conform").setup({
    formatters_by_ft = {
        json5 = { "prettierd" },
    },
})
