require("config.utils").mason_install("kulala-fmt")
require("conform").setup({
    formatters_by_ft = {
        http = { "kulala-fmt" },
    },
})
