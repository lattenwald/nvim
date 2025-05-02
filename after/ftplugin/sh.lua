require("lspconfig").bashls.setup({})

require("config.utils").mason_install("beautysh")
require("conform").setup({
    formatters_by_ft = {
        lua = { "beautysh" },
    },
})
