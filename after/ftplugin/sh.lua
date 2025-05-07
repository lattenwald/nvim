require("config.utils").mason_install("bash-language-server")
require("config.utils").mason_install("beautysh")
require("conform").setup({
    formatters_by_ft = {
        lua = { "beautysh" },
    },
})
