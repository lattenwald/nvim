require("config.utils").lsp_setup("bashls")
require("config.utils").mason_install("beautysh")
require("conform").setup({
    formatters_by_ft = {
        lua = { "beautysh" },
    },
})
