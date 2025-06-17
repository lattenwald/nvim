require("config.utils").mason_install("yaml-language-server")
require("config.utils").mason_install("yamlfmt")
require("conform").setup({
    formatters_by_ft = {
        yaml = { "yamlfmt" },
    },
})
