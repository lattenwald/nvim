require("config.utils").mason_install("kulala-fmt")
require("config.utils").ts_install("http")
require("conform").setup({
    formatters_by_ft = {
        http = { "kulala-fmt" },
    },
})
