require("config.utils").mason_install("stylua")
require("config.utils").mason_install("lua-language-server")
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
    },
})
