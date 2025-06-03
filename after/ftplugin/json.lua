require("config.utils").mason_install("json-lsp")
require("config.utils").mason_install("jq")
require("conform").setup({
    formatters_by_ft = {
        json = { "jq" },
    },
})
